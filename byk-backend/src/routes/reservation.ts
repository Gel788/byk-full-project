import express from 'express';
import { Request, Response } from 'express';
import Reservation from '../models/Reservation';

const router = express.Router();

// Get all reservations
router.get('/', async (req: Request, res: Response) => {
  try {
    const reservations = await Reservation.find();
    res.json({
      success: true,
      data: reservations,
      total: reservations.length,
      page: 1,
      limit: 100
    });
  } catch (error: any) {
    res.status(500).json({ 
      success: false,
      message: error.message,
      data: null
    });
  }
});

// Get user's reservations
router.get('/my', async (req: Request, res: Response) => {
  try {
    // Получаем userId из заголовков или query параметров
    const userId = req.headers['user-id'] || req.query.userId;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
        data: null
      });
    }
    
    // Получаем restaurantId из query параметров (опционально)
    const restaurantId = req.query.restaurantId;
    
    // Строим фильтр запроса
    const filter: any = { userId: userId };
    if (restaurantId) {
      filter.restaurantId = restaurantId;
    }
    
    const reservations = await Reservation.find(filter);
    res.json({
      success: true,
      data: reservations,
      total: reservations.length,
      page: 1,
      limit: 100
    });
  } catch (error: any) {
    res.status(500).json({ 
      success: false,
      message: error.message,
      data: null
    });
  }
});

// Get single reservation
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const reservation = await Reservation.findById(req.params.id);
    if (!reservation) return res.status(404).json({ 
      success: false,
      message: 'Reservation not found',
      data: null
    });
    res.json({
      success: true,
      data: reservation
    });
  } catch (error: any) {
    res.status(500).json({ 
      success: false,
      message: error.message,
      data: null
    });
  }
});

// Create a reservation
router.post('/', async (req: Request, res: Response) => {
  try {
    // Генерируем уникальный номер бронирования
    const timestamp = Date.now();
    const randomStr = Math.random().toString(36).substring(2, 12).toUpperCase();
    const reservationNumber = `RES-${timestamp}-${randomStr}`;
    
    const reservationData = {
      ...req.body,
      reservationNumber: reservationNumber,
      // Преобразуем guests в guestCount если нужно
      guestCount: req.body.guestCount || req.body.guests,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    
    const reservation = new Reservation(reservationData);
    const newReservation = await reservation.save();
    
    res.status(201).json({
      success: true,
      message: 'Бронирование успешно создано',
      data: newReservation
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      message: error.message,
      data: null
    });
  }
});

// Update a reservation
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const updateData = {
      ...req.body,
      updatedAt: new Date()
    };
    
    const updatedReservation = await Reservation.findByIdAndUpdate(req.params.id, updateData, { new: true });
    if (!updatedReservation) return res.status(404).json({
      success: false,
      message: 'Бронирование не найдено',
      data: null
    });
    
    res.json({
      success: true,
      message: 'Бронирование успешно обновлено',
      data: updatedReservation
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
});

// Delete a reservation
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const deletedReservation = await Reservation.findByIdAndDelete(req.params.id);
    if (!deletedReservation) return res.status(404).json({ 
      success: false,
      message: 'Reservation not found',
      data: null
    });
    res.json({ 
      success: true,
      message: 'Reservation deleted',
      data: null
    });
  } catch (error: any) {
    res.status(500).json({ 
      success: false,
      message: error.message,
      data: null
    });
  }
});

export default router;
