"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const News_1 = __importDefault(require("../models/News"));
const router = express_1.default.Router();
// Get all news
router.get('/', async (req, res) => {
    try {
        const news = await News_1.default.find();
        res.json(news);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Get single news
router.get('/:id', async (req, res) => {
    try {
        const newsItem = await News_1.default.findById(req.params.id);
        if (!newsItem)
            return res.status(404).json({ message: 'News not found' });
        res.json(newsItem);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
// Create news
router.post('/', async (req, res) => {
    const news = new News_1.default(req.body);
    try {
        const newNews = await news.save();
        res.status(201).json(newNews);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Update news
router.put('/:id', async (req, res) => {
    try {
        const updatedNews = await News_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedNews)
            return res.status(404).json({ message: 'News not found' });
        res.json(updatedNews);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
});
// Delete news
router.delete('/:id', async (req, res) => {
    try {
        const deletedNews = await News_1.default.findByIdAndDelete(req.params.id);
        if (!deletedNews)
            return res.status(404).json({ message: 'News not found' });
        res.json({ message: 'News deleted' });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
});
exports.default = router;
