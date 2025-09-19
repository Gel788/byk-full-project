import express from 'express';
import { Request, Response } from 'express';
import Restaurant from '../models/Restaurant';

const router = express.Router();

// Get all restaurants
router.get('/', async (req: Request, res: Response) => {
  try {
    const restaurants = await Restaurant.find()
      .populate('brandId', 'name color logo')
      .populate('cityId', 'name country');
    res.json(restaurants);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Get single restaurant
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id)
      .populate('brandId', 'name color logo')
      .populate('cityId', 'name country');
    if (!restaurant) return res.status(404).json({ message: 'Restaurant not found' });
    res.json(restaurant);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Create restaurant
router.post('/', async (req: Request, res: Response) => {
  const restaurant = new Restaurant(req.body);
  try {
    const newRestaurant = await restaurant.save();
    res.status(201).json(newRestaurant);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Update restaurant
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const updatedRestaurant = await Restaurant.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedRestaurant) return res.status(404).json({ message: 'Restaurant not found' });
    res.json(updatedRestaurant);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Delete restaurant
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const deletedRestaurant = await Restaurant.findByIdAndDelete(req.params.id);
    if (!deletedRestaurant) return res.status(404).json({ message: 'Restaurant not found' });
    res.json({ message: 'Restaurant deleted' });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
