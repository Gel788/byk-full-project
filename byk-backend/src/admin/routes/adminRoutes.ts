import express from 'express';
import {
  getDashboardStats,
  getRestaurants,
  getDishes,
  getNews,
  getUsers,
  getOrders,
  getReservations
} from '../controllers/adminController';

const router = express.Router();

// Админ роуты
router.get('/dashboard', getDashboardStats);
router.get('/restaurants', getRestaurants);
router.get('/dishes', getDishes);
router.get('/news', getNews);
router.get('/users', getUsers);
router.get('/orders', getOrders);
router.get('/reservations', getReservations);

export default router;
