"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getReservations = exports.getOrders = exports.getUsers = exports.getNews = exports.getDishes = exports.getRestaurants = exports.getDashboardStats = void 0;
const Restaurant_1 = __importDefault(require("../../models/Restaurant"));
const Dish_1 = __importDefault(require("../../models/Dish"));
const News_1 = __importDefault(require("../../models/News"));
const User_1 = __importDefault(require("../../models/User"));
const Order_1 = __importDefault(require("../../models/Order"));
const Reservation_1 = __importDefault(require("../../models/Reservation"));
// Получить статистику
const getDashboardStats = async (req, res) => {
    try {
        const [restaurants, dishes, news, users] = await Promise.all([
            Restaurant_1.default.countDocuments(),
            Dish_1.default.countDocuments(),
            News_1.default.countDocuments(),
            User_1.default.countDocuments()
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
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка получения статистики',
            error: error instanceof Error ? error.message : 'Неизвестная ошибка'
        });
    }
};
exports.getDashboardStats = getDashboardStats;
// Получить все рестораны для админки
const getRestaurants = async (req, res) => {
    try {
        const restaurants = await Restaurant_1.default.find()
            .sort({ createdAt: -1 })
            .limit(50);
        res.json({
            success: true,
            data: restaurants,
            count: restaurants.length
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка получения ресторанов',
            error: error instanceof Error ? error.message : 'Неизвестная ошибка'
        });
    }
};
exports.getRestaurants = getRestaurants;
// Получить все блюда для админки
const getDishes = async (req, res) => {
    try {
        const dishes = await Dish_1.default.find()
            .populate('restaurantId', 'name brand')
            .sort({ createdAt: -1 })
            .limit(100);
        res.json({
            success: true,
            data: dishes,
            count: dishes.length
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка получения блюд',
            error: error instanceof Error ? error.message : 'Неизвестная ошибка'
        });
    }
};
exports.getDishes = getDishes;
// Получить все новости для админки
const getNews = async (req, res) => {
    try {
        const news = await News_1.default.find()
            .sort({ createdAt: -1 })
            .limit(50);
        res.json({
            success: true,
            data: news,
            count: news.length
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка получения новостей',
            error: error instanceof Error ? error.message : 'Неизвестная ошибка'
        });
    }
};
exports.getNews = getNews;
// Получить всех пользователей для админки
const getUsers = async (req, res) => {
    try {
        const users = await User_1.default.find()
            .select('-password')
            .sort({ createdAt: -1 })
            .limit(100);
        res.json({
            success: true,
            data: users,
            count: users.length
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка получения пользователей',
            error: error instanceof Error ? error.message : 'Неизвестная ошибка'
        });
    }
};
exports.getUsers = getUsers;
// Получить все заказы для админки
const getOrders = async (req, res) => {
    try {
        const orders = await Order_1.default.find()
            .populate('userId', 'username fullName')
            .populate('restaurantId', 'name brand')
            .sort({ createdAt: -1 })
            .limit(100);
        res.json({
            success: true,
            data: orders,
            count: orders.length
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка получения заказов',
            error: error instanceof Error ? error.message : 'Неизвестная ошибка'
        });
    }
};
exports.getOrders = getOrders;
// Получить все резервации для админки
const getReservations = async (req, res) => {
    try {
        const reservations = await Reservation_1.default.find()
            .populate('userId', 'username fullName')
            .populate('restaurantId', 'name brand')
            .sort({ createdAt: -1 })
            .limit(100);
        res.json({
            success: true,
            data: reservations,
            count: reservations.length
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка получения резерваций',
            error: error instanceof Error ? error.message : 'Неизвестная ошибка'
        });
    }
};
exports.getReservations = getReservations;
