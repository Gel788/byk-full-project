import express, { Request, Response } from 'express';
import Brand from '../models/Brand';

const router = express.Router();

// Получить все бренды
router.get('/', async (req: Request, res: Response) => {
  try {
    const brands = await Brand.find().sort({ name: 1 });
    res.json(brands);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Получить бренд по ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const brand = await Brand.findById(req.params.id);
    if (!brand) return res.status(404).json({ message: 'Brand not found' });
    res.json(brand);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Создать новый бренд
router.post('/', async (req: Request, res: Response) => {
  try {
    const brand = new Brand(req.body);
    await brand.save();
    res.status(201).json(brand);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Обновить бренд
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const brand = await Brand.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!brand) return res.status(404).json({ message: 'Brand not found' });
    res.json(brand);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Удалить бренд
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const brand = await Brand.findByIdAndDelete(req.params.id);
    if (!brand) return res.status(404).json({ message: 'Brand not found' });
    res.json({ message: 'Brand deleted successfully' });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
