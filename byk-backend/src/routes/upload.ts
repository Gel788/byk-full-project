import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { Request, Response } from 'express';

const router = express.Router();

// Настройка multer для загрузки файлов
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = process.env.NODE_ENV === 'production' ? './uploads/' : './uploads/';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Получить список файлов
router.get('/files', async (req: Request, res: Response) => {
  try {
    const uploadDir = process.env.NODE_ENV === 'production' ? '/var/www/uploads/' : './uploads/';
    if (!fs.existsSync(uploadDir)) {
      return res.json({
        success: true,
        data: [],
        count: 0
      });
    }

    const files = fs.readdirSync(uploadDir).map(file => ({
      filename: file,
      originalName: file,
      name: file,
      size: fs.statSync(path.join(uploadDir, file)).size,
      uploadDate: fs.statSync(path.join(uploadDir, file)).mtime,
        url: process.env.NODE_ENV === 'production' ? `https://bulladmin.ru/api/uploads/${file}` : `http://localhost:5001/api/uploads/${file}`
    }));

    res.json({
      success: true,
      data: files,
      count: files.length
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Ошибка получения файлов',
      error: error.message
    });
  }
});

// Загрузить один файл
router.post('/upload', upload.single('file'), (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Файл не был загружен'
      });
    }

    res.json({
      success: true,
      message: 'Файл успешно загружен',
      data: {
        filename: req.file.filename,
        originalName: req.file.originalname,
        size: req.file.size,
        path: req.file.path,
        url: process.env.NODE_ENV === 'production' ? `https://bulladmin.ru/api/uploads/${req.file.filename}` : `http://localhost:5001/api/uploads/${req.file.filename}`
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Ошибка загрузки файла',
      error: error.message
    });
  }
});

// Загрузить несколько файлов
router.post('/upload-multiple', upload.array('files', 10), (req: Request, res: Response) => {
  try {
    if (!req.files || (req.files as Express.Multer.File[]).length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Файлы не были загружены'
      });
    }

    const files = (req.files as Express.Multer.File[]).map(file => ({
      filename: file.filename,
      originalName: file.originalname,
      size: file.size,
      path: file.path,
      url: `https://bulladmin.ru/api/uploads/${file.filename}`
    }));

    res.json({
      success: true,
      message: 'Файлы успешно загружены',
      data: files,
      count: files.length
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Ошибка загрузки файлов',
      error: error.message
    });
  }
});

// Удалить файл
router.delete('/files/:filename', (req: Request, res: Response) => {
  try {
    const filename = req.params.filename;
    const filePath = path.join('/var/www/uploads', filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        message: 'Файл не найден'
      });
    }

    fs.unlinkSync(filePath);

    res.json({
      success: true,
      message: 'Файл успешно удален'
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Ошибка удаления файла',
      error: error.message
    });
  }
});

export default router;
