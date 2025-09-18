import { Request, Response } from 'express';
import Restaurant from '../../models/Restaurant';
import Dish from '../../models/Dish';
import News from '../../models/News';
import User from '../../models/User';
import Order from '../../models/Order';
import Reservation from '../../models/Reservation';

// Получить статистику
export const getDashboardStats = async (req: Request, res: Response) => {
  try {
    const [restaurants, dishes, news, users] = await Promise.all([
      Restaurant.countDocuments(),
      Dish.countDocuments(),
      News.countDocuments(),
      User.countDocuments()
    ]);

    res.json({
      success: true,
      data: {
        restaurants,
        dishes,
        news,
        users,
        totalRevenue: 0,
        activeOrders: 0
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка получения статистики',
      error: error instanceof Error ? error.message : 'Неизвестная ошибка'
    });
  }
};

// Получить все рестораны для админки
export const getRestaurants = async (req: Request, res: Response) => {
  try {
    const restaurants = await Restaurant.find()
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({
      success: true,
      data: restaurants,
      count: restaurants.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка получения ресторанов',
      error: error instanceof Error ? error.message : 'Неизвестная ошибка'
    });
  }
};

// Получить все блюда для админки
export const getDishes = async (req: Request, res: Response) => {
  try {
    const dishes = await Dish.find()
      .populate('restaurantId', 'name brand')
      .sort({ createdAt: -1 })
      .limit(100);

    res.json({
      success: true,
      data: dishes,
      count: dishes.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка получения блюд',
      error: error instanceof Error ? error.message : 'Неизвестная ошибка'
    });
  }
};

// Получить все новости для админки
export const getNews = async (req: Request, res: Response) => {
  try {
    const news = await News.find()
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({
      success: true,
      data: news,
      count: news.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка получения новостей',
      error: error instanceof Error ? error.message : 'Неизвестная ошибка'
    });
  }
};

// Получить всех пользователей для админки
export const getUsers = async (req: Request, res: Response) => {
  try {
    const users = await User.find()
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(100);

    res.json({
      success: true,
      data: users,
      count: users.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка получения пользователей',
      error: error instanceof Error ? error.message : 'Неизвестная ошибка'
    });
  }
};

// Получить все заказы для админки
export const getOrders = async (req: Request, res: Response) => {
  try {
    const orders = await Order.find()
      .populate('userId', 'username fullName')
      .populate('restaurantId', 'name brand')
      .sort({ createdAt: -1 })
      .limit(100);

    res.json({
      success: true,
      data: orders,
      count: orders.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка получения заказов',
      error: error instanceof Error ? error.message : 'Неизвестная ошибка'
    });
  }
};

// Получить все резервации для админки
export const getReservations = async (req: Request, res: Response) => {
  try {
    const reservations = await Reservation.find()
      .populate('userId', 'username fullName')
      .populate('restaurantId', 'name brand')
      .sort({ createdAt: -1 })
      .limit(100);

    res.json({
      success: true,
      data: reservations,
      count: reservations.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка получения резерваций',
      error: error instanceof Error ? error.message : 'Неизвестная ошибка'
    });
  }
};
