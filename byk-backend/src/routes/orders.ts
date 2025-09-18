import express from 'express';
import { Request, Response } from 'express';
import Order from '../models/Order';

const router = express.Router();

// Get all orders
router.get('/', async (req: Request, res: Response) => {
  try {
    const orders = await Order.find()
      .populate('userId', 'username fullName')
      .populate('restaurantId', 'name brand');
    res.json(orders);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Get single order
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('userId', 'username fullName')
      .populate('restaurantId', 'name brand');
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Create an order
router.post('/', async (req: Request, res: Response) => {
  const order = new Order(req.body);
  try {
    const newOrder = await order.save();
    res.status(201).json(newOrder);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Update an order
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const updatedOrder = await Order.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedOrder) return res.status(404).json({ message: 'Order not found' });
    res.json(updatedOrder);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Delete an order
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const deletedOrder = await Order.findByIdAndDelete(req.params.id);
    if (!deletedOrder) return res.status(404).json({ message: 'Order not found' });
    res.json({ message: 'Order deleted' });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

export default router;