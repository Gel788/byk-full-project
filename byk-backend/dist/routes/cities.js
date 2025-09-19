"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const City_1 = __importDefault(require("../models/City"));
const router = express_1.default.Router();
// Получить все города
router.get('/', async (req, res) => {
    try {
        const cities = await City_1.default.find().sort({ name: 1 });
        res.json(cities);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Получить город по ID
router.get('/:id', async (req, res) => {
    try {
        const city = await City_1.default.findById(req.params.id);
        if (!city)
            return res.status(404).json({ message: 'City not found' });
        res.json(city);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Создать новый город
router.post('/', async (req, res) => {
    try {
        const city = new City_1.default(req.body);
        await city.save();
        res.status(201).json(city);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Обновить город
router.put('/:id', async (req, res) => {
    try {
        const city = await City_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!city)
            return res.status(404).json({ message: 'City not found' });
        res.json(city);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Удалить город
router.delete('/:id', async (req, res) => {
    try {
        const city = await City_1.default.findByIdAndDelete(req.params.id);
        if (!city)
            return res.status(404).json({ message: 'City not found' });
        res.json({ message: 'City deleted successfully' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
