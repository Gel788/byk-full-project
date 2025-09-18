import express from 'express';
import { Request, Response } from 'express';
import Dish from '../models/Dish';

const router = express.Router();

// Get all dishes
router.get('/', async (req: Request, res: Response) => {
  try {
    const dishes = await Dish.find().populate('restaurantId', 'name brand');
    res.json(dishes);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Get single dish
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const dish = await Dish.findById(req.params.id).populate('restaurantId', 'name brand');
    if (!dish) return res.status(404).json({ message: 'Dish not found' });
    res.json(dish);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Create dish
router.post('/', async (req: Request, res: Response) => {
  const dish = new Dish(req.body);
  try {
    const newDish = await dish.save();
    res.status(201).json(newDish);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Update dish
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const updatedDish = await Dish.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedDish) return res.status(404).json({ message: 'Dish not found' });
    res.json(updatedDish);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Delete dish
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const deletedDish = await Dish.findByIdAndDelete(req.params.id);
    if (!deletedDish) return res.status(404).json({ message: 'Dish not found' });
    res.json({ message: 'Dish deleted' });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
