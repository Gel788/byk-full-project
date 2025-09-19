"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Restaurant_1 = __importDefault(require("../models/Restaurant"));
const router = express_1.default.Router();
// Get all restaurants
router.get('/', async (req, res) => {
    try {
        const restaurants = await Restaurant_1.default.find()
            .populate('brandId', 'name color logo')
            .populate('cityId', 'name country');
        res.json(restaurants);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Get single restaurant
router.get('/:id', async (req, res) => {
    try {
        const restaurant = await Restaurant_1.default.findById(req.params.id)
            .populate('brandId', 'name color logo')
            .populate('cityId', 'name country');
        if (!restaurant)
            return res.status(404).json({ message: 'Restaurant not found' });
        res.json(restaurant);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Create restaurant
router.post('/', async (req, res) => {
    const restaurant = new Restaurant_1.default(req.body);
    try {
        const newRestaurant = await restaurant.save();
        res.status(201).json(newRestaurant);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Update restaurant
router.put('/:id', async (req, res) => {
    try {
        const updatedRestaurant = await Restaurant_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedRestaurant)
            return res.status(404).json({ message: 'Restaurant not found' });
        res.json(updatedRestaurant);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Delete restaurant
router.delete('/:id', async (req, res) => {
    try {
        const deletedRestaurant = await Restaurant_1.default.findByIdAndDelete(req.params.id);
        if (!deletedRestaurant)
            return res.status(404).json({ message: 'Restaurant not found' });
        res.json({ message: 'Restaurant deleted' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
