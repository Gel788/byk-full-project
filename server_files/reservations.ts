import express, { Request, Response } from 'express';
import Reservation, { IReservation } from './Reservation';
import { authenticateToken } from './auth';

const router = express.Router();

// Получить все резервации пользователя
router.get('/my', authenticateToken, async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id;
    const { page = 1, limit = 10, status } = req.query;
    
    const filter: any = { userId };
    if (status) {
      filter.status = status;
    }
    
    const reservations = await Reservation.find(filter)
      .sort({ date: -1 })
      .limit(Number(limit) * 1)
      .skip((Number(page) - 1) * Number(limit));
    
    const total = await Reservation.countDocuments(filter);
    
    res.json({
      success: true,
      data: reservations,
      total,
      page: Number(page),
      limit: Number(limit)
    });
    
  } catch (error: any) {
    console.error('Ошибка получения резерваций:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при получении резерваций'
    });
  }
});

// Получить резервацию по ID
router.get('/:id', authenticateToken, async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const userId = (req as any).user._id;
    
    const reservation = await Reservation.findOne({ _id: id, userId });
    
    if (!reservation) {
      return res.status(404).json({
        success: false,
        message: 'Резервация не найдена'
      });
    }
    
    res.json({
      success: true,
      data: reservation
    });
    
  } catch (error: any) {
    console.error('Ошибка получения резервации:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при получении резервации'
    });
  }
});

// Создать новую резервацию
router.post('/', authenticateToken, async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id;
    const {
      restaurantId,
      restaurantName,
      date,
      guestCount,
      tableNumber,
      specialRequests,
      contactPhone,
      contactName
    } = req.body;
    
    // Валидация
    if (!restaurantId || !restaurantName || !date || !guestCount || !tableNumber) {
      return res.status(400).json({
        success: false,
        message: 'Необходимо указать все обязательные поля'
      });
    }
    
    // Проверка даты (нельзя бронировать в прошлом)
    const reservationDate = new Date(date);
    if (reservationDate < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'Нельзя бронировать стол в прошлом'
      });
    }
    
    // Проверка доступности стола
    const existingReservation = await Reservation.findOne({
      restaurantId,
      tableNumber,
      date: {
        $gte: new Date(reservationDate.getTime() - 2 * 60 * 60 * 1000), // 2 часа до
        $lte: new Date(reservationDate.getTime() + 2 * 60 * 60 * 1000)  // 2 часа после
      },
      status: { $in: ['pending', 'confirmed'] }
    });
    
    if (existingReservation) {
      return res.status(409).json({
        success: false,
        message: 'Стол уже забронирован на это время'
      });
    }
    
    // Создание резервации
    const reservation = new Reservation({
      restaurantId,
      restaurantName,
      userId,
      date: reservationDate,
      guestCount,
      tableNumber,
      specialRequests,
      contactPhone,
      contactName
    });
    
    await reservation.save();
    
    res.status(201).json({
      success: true,
      message: 'Резервация успешно создана',
      data: reservation
    });
    
  } catch (error: any) {
    console.error('Ошибка создания резервации:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при создании резервации'
    });
  }
});

// Обновить резервацию
router.put('/:id', authenticateToken, async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const userId = (req as any).user._id;
    const { status, specialRequests } = req.body;
    
    const reservation = await Reservation.findOne({ _id: id, userId });
    
    if (!reservation) {
      return res.status(404).json({
        success: false,
        message: 'Резервация не найдена'
      });
    }
    
    // Проверка, можно ли изменить резервацию
    if (reservation.status === 'completed' || reservation.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Нельзя изменить завершенную или отмененную резервацию'
      });
    }
    
    // Обновление полей
    if (status) {
      reservation.status = status;
    }
    if (specialRequests !== undefined) {
      reservation.specialRequests = specialRequests;
    }
    
    await reservation.save();
    
    res.json({
      success: true,
      message: 'Резервация успешно обновлена',
      data: reservation
    });
    
  } catch (error: any) {
    console.error('Ошибка обновления резервации:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при обновлении резервации'
    });
  }
});

// Отменить резервацию
router.delete('/:id', authenticateToken, async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const userId = (req as any).user._id;
    const { reason } = req.body;
    
    const reservation = await Reservation.findOne({ _id: id, userId });
    
    if (!reservation) {
      return res.status(404).json({
        success: false,
        message: 'Резервация не найдена'
      });
    }
    
    // Проверка, можно ли отменить резервацию
    if (reservation.status === 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Нельзя отменить завершенную резервацию'
      });
    }
    
    if (reservation.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Резервация уже отменена'
      });
    }
    
    // Отмена резервации
    reservation.status = 'cancelled';
    if (reason) {
      reservation.specialRequests = reason;
    }
    
    await reservation.save();
    
    res.json({
      success: true,
      message: 'Резервация успешно отменена'
    });
    
  } catch (error: any) {
    console.error('Ошибка отмены резервации:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при отмене резервации'
    });
  }
});

// Получить доступные столы для ресторана
router.get('/available-tables/:restaurantId', authenticateToken, async (req: Request, res: Response) => {
  try {
    const { restaurantId } = req.params;
    const { date, guestCount } = req.query;
    
    if (!date) {
      return res.status(400).json({
        success: false,
        message: 'Необходимо указать дату'
      });
    }
    
    const requestedDate = new Date(date as string);
    
    // Получаем все резервации на эту дату
    const reservations = await Reservation.find({
      restaurantId,
      date: {
        $gte: new Date(requestedDate.getTime() - 2 * 60 * 60 * 1000), // 2 часа до
        $lte: new Date(requestedDate.getTime() + 2 * 60 * 60 * 1000)  // 2 часа после
      },
      status: { $in: ['pending', 'confirmed'] }
    });
    
    // Получаем забронированные номера столов
    const bookedTableNumbers = reservations.map(r => r.tableNumber);
    
    // Генерируем доступные столы (это упрощенная версия, в реальности нужно получать из базы столов)
    const availableTables = [];
    for (let i = 1; i <= 20; i++) {
      if (!bookedTableNumbers.includes(i)) {
        availableTables.push({
          tableNumber: i,
          capacity: Math.max(2, Math.min(8, i % 4 + 2)), // Примерная логика вместимости
          location: ['Основной зал', 'Терраса', 'VIP-зона', 'У окна'][i % 4],
          isAvailable: true,
          availableTimes: ['18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00', '21:30']
        });
      }
    }
    
    // Фильтруем по количеству гостей если указано
    let filteredTables = availableTables;
    if (guestCount) {
      filteredTables = availableTables.filter(table => table.capacity >= Number(guestCount));
    }
    
    res.json({
      success: true,
      data: filteredTables
    });
    
  } catch (error: any) {
    console.error('Ошибка получения доступных столов:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при получении доступных столов'
    });
  }
});

export default router;
