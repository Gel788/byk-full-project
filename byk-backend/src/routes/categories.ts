import express, { Request, Response } from 'express';
import Category from '../models/Category';

const router = express.Router();

// Получить все категории
router.get('/', async (req: Request, res: Response) => {
  try {
    const categories = await Category.find().populate('brandId', 'name').sort({ order: 1 });
    res.json(categories);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Получить категории по бренду
router.get('/brand/:brandId', async (req: Request, res: Response) => {
  try {
    const categories = await Category.find({ brandId: req.params.brandId }).sort({ order: 1 });
    res.json(categories);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Получить категорию по ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const category = await Category.findById(req.params.id).populate('brandId', 'name');
    if (!category) return res.status(404).json({ message: 'Category not found' });
    res.json(category);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Создать новую категорию
router.post('/', async (req: Request, res: Response) => {
  try {
    const category = new Category(req.body);
    await category.save();
    await category.populate('brandId', 'name');
    res.status(201).json(category);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Обновить категорию
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const category = await Category.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate('brandId', 'name');
    if (!category) return res.status(404).json({ message: 'Category not found' });
    res.json(category);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Удалить категорию
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const category = await Category.findByIdAndDelete(req.params.id);
    if (!category) return res.status(404).json({ message: 'Category not found' });
    res.json({ message: 'Category deleted successfully' });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
