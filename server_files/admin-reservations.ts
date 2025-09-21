import express, { Request, Response } from 'express';
import Reservation, { IReservation } from './Reservation';

const router = express.Router();

// Получить все резервации для админки
router.get('/admin/reservations', async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 50, status, restaurantId } = req.query;
    
    const filter: any = {};
    if (status) {
      filter.status = status;
    }
    if (restaurantId) {
      filter.restaurantId = restaurantId;
    }
    
    const reservations = await Reservation.find(filter)
      .sort({ date: -1 })
      .limit(Number(limit) * 1)
      .skip((Number(page) - 1) * Number(limit))
      .populate('userId', 'phoneNumber fullName')
      .populate('restaurantId', 'name');
    
    const total = await Reservation.countDocuments(filter);
    
    res.json({
      success: true,
      data: reservations,
      total,
      page: Number(page),
      limit: Number(limit)
    });
    
  } catch (error: any) {
    console.error('Ошибка получения резерваций для админки:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при получении резерваций'
    });
  }
});

// Получить резервацию по ID для админки
router.get('/admin/reservations/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const reservation = await Reservation.findById(id)
      .populate('userId', 'phoneNumber fullName email')
      .populate('restaurantId', 'name address phone');
    
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
    console.error('Ошибка получения резервации для админки:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при получении резервации'
    });
  }
});

// Обновить резервацию (статус, особые пожелания)
router.put('/admin/reservations/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { status, specialRequests } = req.body;
    
    const reservation = await Reservation.findById(id);
    
    if (!reservation) {
      return res.status(404).json({
        success: false,
        message: 'Резервация не найдена'
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
    console.error('Ошибка обновления резервации в админке:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при обновлении резервации'
    });
  }
});

// Отменить резервацию
router.delete('/admin/reservations/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    
    const reservation = await Reservation.findById(id);
    
    if (!reservation) {
      return res.status(404).json({
        success: false,
        message: 'Резервация не найдена'
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
    console.error('Ошибка отмены резервации в админке:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при отмене резервации'
    });
  }
});

// Получить статистику резерваций
router.get('/admin/reservations/stats/summary', async (req: Request, res: Response) => {
  try {
    const totalReservations = await Reservation.countDocuments();
    const pendingReservations = await Reservation.countDocuments({ status: 'pending' });
    const confirmedReservations = await Reservation.countDocuments({ status: 'confirmed' });
    const completedReservations = await Reservation.countDocuments({ status: 'completed' });
    const cancelledReservations = await Reservation.countDocuments({ status: 'cancelled' });
    
    // Резервации за последние 30 дней
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const recentReservations = await Reservation.countDocuments({
      createdAt: { $gte: thirtyDaysAgo }
    });
    
    res.json({
      success: true,
      data: {
        total: totalReservations,
        pending: pendingReservations,
        confirmed: confirmedReservations,
        completed: completedReservations,
        cancelled: cancelledReservations,
        recent: recentReservations
      }
    });
    
  } catch (error: any) {
    console.error('Ошибка получения статистики резерваций:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при получении статистики'
    });
  }
});

export default router;
