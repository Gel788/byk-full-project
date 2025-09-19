import express, { Request, Response } from 'express';
import City from '../models/City';

const router = express.Router();

// Получить все города
router.get('/', async (req: Request, res: Response) => {
  try {
    const cities = await City.find().sort({ name: 1 });
    res.json(cities);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Получить город по ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const city = await City.findById(req.params.id);
    if (!city) return res.status(404).json({ message: 'City not found' });
    res.json(city);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Создать новый город
router.post('/', async (req: Request, res: Response) => {
  try {
    const city = new City(req.body);
    await city.save();
    res.status(201).json(city);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Обновить город
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const city = await City.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!city) return res.status(404).json({ message: 'City not found' });
    res.json(city);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Удалить город
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const city = await City.findByIdAndDelete(req.params.id);
    if (!city) return res.status(404).json({ message: 'City not found' });
    res.json({ message: 'City deleted successfully' });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
