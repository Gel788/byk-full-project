"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Reservation_1 = __importDefault(require("../models/Reservation"));
const router = express_1.default.Router();
// Get all reservations
router.get('/', async (req, res) => {
    try {
        const reservations = await Reservation_1.default.find();
        res.json(reservations);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Get single reservation
router.get('/:id', async (req, res) => {
    try {
        const reservation = await Reservation_1.default.findById(req.params.id);
        if (!reservation)
            return res.status(404).json({ message: 'Reservation not found' });
        res.json(reservation);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Create a reservation
router.post('/', async (req, res) => {
    try {
        // Генерируем номер бронирования автоматически
        const count = await Reservation_1.default.countDocuments();
        const reservationNumber = `RES-${String(count + 1).padStart(3, '0')}`;
        const reservationData = {
            ...req.body,
            reservationNumber: reservationNumber,
            createdAt: new Date(),
            updatedAt: new Date()
        };
        const reservation = new Reservation_1.default(reservationData);
        const newReservation = await reservation.save();
        res.status(201).json({
            success: true,
            message: 'Бронирование успешно создано',
            data: newReservation
        });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
});
// Update a reservation
router.put('/:id', async (req, res) => {
    try {
        const updateData = {
            ...req.body,
            updatedAt: new Date()
        };
        const updatedReservation = await Reservation_1.default.findByIdAndUpdate(req.params.id, updateData, { new: true });
        if (!updatedReservation)
            return res.status(404).json({
                success: false,
                message: 'Бронирование не найдено'
            });
        res.json({
            success: true,
            message: 'Бронирование успешно обновлено',
            data: updatedReservation
        });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
});
// Delete a reservation
router.delete('/:id', async (req, res) => {
    try {
        const deletedReservation = await Reservation_1.default.findByIdAndDelete(req.params.id);
        if (!deletedReservation)
            return res.status(404).json({ message: 'Reservation not found' });
        res.json({ message: 'Reservation deleted' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
