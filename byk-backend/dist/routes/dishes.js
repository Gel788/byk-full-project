"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Dish_1 = __importDefault(require("../models/Dish"));
const router = express_1.default.Router();
// Get all dishes
router.get('/', async (req, res) => {
    try {
        const dishes = await Dish_1.default.find().populate('restaurantId', 'name brand');
        res.json(dishes);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Get single dish
router.get('/:id', async (req, res) => {
    try {
        const dish = await Dish_1.default.findById(req.params.id).populate('restaurantId', 'name brand');
        if (!dish)
            return res.status(404).json({ message: 'Dish not found' });
        res.json(dish);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Create dish
router.post('/', async (req, res) => {
    const dish = new Dish_1.default(req.body);
    try {
        const newDish = await dish.save();
        res.status(201).json(newDish);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Update dish
router.put('/:id', async (req, res) => {
    try {
        const updatedDish = await Dish_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedDish)
            return res.status(404).json({ message: 'Dish not found' });
        res.json(updatedDish);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Delete dish
router.delete('/:id', async (req, res) => {
    try {
        const deletedDish = await Dish_1.default.findByIdAndDelete(req.params.id);
        if (!deletedDish)
            return res.status(404).json({ message: 'Dish not found' });
        res.json({ message: 'Dish deleted' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
