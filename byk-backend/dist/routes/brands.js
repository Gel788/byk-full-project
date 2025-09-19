"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Brand_1 = __importDefault(require("../models/Brand"));
const router = express_1.default.Router();
// Получить все бренды
router.get('/', async (req, res) => {
    try {
        const brands = await Brand_1.default.find().sort({ name: 1 });
        res.json(brands);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Получить бренд по ID
router.get('/:id', async (req, res) => {
    try {
        const brand = await Brand_1.default.findById(req.params.id);
        if (!brand)
            return res.status(404).json({ message: 'Brand not found' });
        res.json(brand);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Создать новый бренд
router.post('/', async (req, res) => {
    try {
        const brand = new Brand_1.default(req.body);
        await brand.save();
        res.status(201).json(brand);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Обновить бренд
router.put('/:id', async (req, res) => {
    try {
        const brand = await Brand_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!brand)
            return res.status(404).json({ message: 'Brand not found' });
        res.json(brand);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Удалить бренд
router.delete('/:id', async (req, res) => {
    try {
        const brand = await Brand_1.default.findByIdAndDelete(req.params.id);
        if (!brand)
            return res.status(404).json({ message: 'Brand not found' });
        res.json({ message: 'Brand deleted successfully' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
