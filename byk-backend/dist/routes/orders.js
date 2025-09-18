"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Order_1 = __importDefault(require("../models/Order"));
const router = express_1.default.Router();
// Get all orders
router.get('/', async (req, res) => {
    try {
        const orders = await Order_1.default.find()
            .populate('userId', 'username fullName')
            .populate('restaurantId', 'name brand');
        res.json(orders);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Get single order
router.get('/:id', async (req, res) => {
    try {
        const order = await Order_1.default.findById(req.params.id)
            .populate('userId', 'username fullName')
            .populate('restaurantId', 'name brand');
        if (!order)
            return res.status(404).json({ message: 'Order not found' });
        res.json(order);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Create an order
router.post('/', async (req, res) => {
    const order = new Order_1.default(req.body);
    try {
        const newOrder = await order.save();
        res.status(201).json(newOrder);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Update an order
router.put('/:id', async (req, res) => {
    try {
        const updatedOrder = await Order_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedOrder)
            return res.status(404).json({ message: 'Order not found' });
        res.json(updatedOrder);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Delete an order
router.delete('/:id', async (req, res) => {
    try {
        const deletedOrder = await Order_1.default.findByIdAndDelete(req.params.id);
        if (!deletedOrder)
            return res.status(404).json({ message: 'Order not found' });
        res.json({ message: 'Order deleted' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
