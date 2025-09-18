"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const User_1 = __importDefault(require("../models/User"));
const router = express_1.default.Router();
// Get all users
router.get('/', async (req, res) => {
    try {
        const users = await User_1.default.find();
        res.json(users);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Get single user
router.get('/:id', async (req, res) => {
    try {
        const user = await User_1.default.findById(req.params.id);
        if (!user)
            return res.status(404).json({ message: 'User not found' });
        res.json(user);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Update user
router.put('/:id', async (req, res) => {
    try {
        const updatedUser = await User_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedUser)
            return res.status(404).json({ message: 'User not found' });
        res.json(updatedUser);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Delete user
router.delete('/:id', async (req, res) => {
    try {
        const deletedUser = await User_1.default.findByIdAndDelete(req.params.id);
        if (!deletedUser)
            return res.status(404).json({ message: 'User not found' });
        res.json({ message: 'User deleted' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
