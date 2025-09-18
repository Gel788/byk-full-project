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
    const reservation = new Reservation_1.default(req.body);
    try {
        const newReservation = await reservation.save();
        res.status(201).json(newReservation);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Update a reservation
router.put('/:id', async (req, res) => {
    try {
        const updatedReservation = await Reservation_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedReservation)
            return res.status(404).json({ message: 'Reservation not found' });
        res.json(updatedReservation);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
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
