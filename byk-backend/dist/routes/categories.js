"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Category_1 = __importDefault(require("../models/Category"));
const router = express_1.default.Router();
// Получить все категории
router.get('/', async (req, res) => {
    try {
        const categories = await Category_1.default.find().populate('brandId', 'name').sort({ order: 1 });
        res.json(categories);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Получить категории по бренду
router.get('/brand/:brandId', async (req, res) => {
    try {
        const categories = await Category_1.default.find({ brandId: req.params.brandId }).sort({ order: 1 });
        res.json(categories);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Получить категорию по ID
router.get('/:id', async (req, res) => {
    try {
        const category = await Category_1.default.findById(req.params.id).populate('brandId', 'name');
        if (!category)
            return res.status(404).json({ message: 'Category not found' });
        res.json(category);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Создать новую категорию
router.post('/', async (req, res) => {
    try {
        const category = new Category_1.default(req.body);
        await category.save();
        await category.populate('brandId', 'name');
        res.status(201).json(category);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Обновить категорию
router.put('/:id', async (req, res) => {
    try {
        const category = await Category_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate('brandId', 'name');
        if (!category)
            return res.status(404).json({ message: 'Category not found' });
        res.json(category);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Удалить категорию
router.delete('/:id', async (req, res) => {
    try {
        const category = await Category_1.default.findByIdAndDelete(req.params.id);
        if (!category)
            return res.status(404).json({ message: 'Category not found' });
        res.json({ message: 'Category deleted successfully' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
