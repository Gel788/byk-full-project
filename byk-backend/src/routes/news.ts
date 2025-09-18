import express from 'express';
import { Request, Response } from 'express';
import News from '../models/News';

const router = express.Router();

// Get all news
router.get('/', async (req: Request, res: Response) => {
  try {
    const news = await News.find();
    res.json(news);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Get single news
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const newsItem = await News.findById(req.params.id);
    if (!newsItem) return res.status(404).json({ message: 'News not found' });
    res.json(newsItem);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Create news
router.post('/', async (req: Request, res: Response) => {
  const news = new News(req.body);
  try {
    const newNews = await news.save();
    res.status(201).json(newNews);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Update news
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const updatedNews = await News.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedNews) return res.status(404).json({ message: 'News not found' });
    res.json(updatedNews);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

// Delete news
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const deletedNews = await News.findByIdAndDelete(req.params.id);
    if (!deletedNews) return res.status(404).json({ message: 'News not found' });
    res.json({ message: 'News deleted' });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
