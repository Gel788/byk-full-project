"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const adminController_1 = require("../controllers/adminController");
const router = express_1.default.Router();
// Админ роуты
router.get('/dashboard', adminController_1.getDashboardStats);
router.get('/restaurants', adminController_1.getRestaurants);
router.get('/dishes', adminController_1.getDishes);
router.get('/news', adminController_1.getNews);
router.get('/users', adminController_1.getUsers);
router.get('/orders', adminController_1.getOrders);
router.get('/reservations', adminController_1.getReservations);
exports.default = router;
