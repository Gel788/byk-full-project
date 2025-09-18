"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const router = express_1.default.Router();
// Настройка multer для загрузки файлов
const storage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = 'uploads/';
        if (!fs_1.default.existsSync(uploadDir)) {
            fs_1.default.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path_1.default.extname(file.originalname));
    }
});
const upload = (0, multer_1.default)({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB limit
    }
});
// Получить список файлов
router.get('/files', async (req, res) => {
    try {
        const uploadDir = 'uploads/';
        if (!fs_1.default.existsSync(uploadDir)) {
            return res.json({
                success: true,
                data: [],
                count: 0
            });
        }
        const files = fs_1.default.readdirSync(uploadDir).map(file => ({
            filename: file,
            originalName: file,
            name: file,
            size: fs_1.default.statSync(path_1.default.join(uploadDir, file)).size,
            uploadDate: fs_1.default.statSync(path_1.default.join(uploadDir, file)).mtime,
            url: `http://localhost:5001/uploads/${file}`
        }));
        res.json({
            success: true,
            data: files,
            count: files.length
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка получения файлов',
            error: error.message
        });
    }
});
// Загрузить один файл
router.post('/upload', upload.single('file'), (req, res) => {
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
                url: `http://localhost:5001/uploads/${req.file.filename}`
            }
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка загрузки файла',
            error: error.message
        });
    }
});
// Загрузить несколько файлов
router.post('/upload-multiple', upload.array('files', 10), (req, res) => {
    try {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Файлы не были загружены'
            });
        }
        const files = req.files.map(file => ({
            filename: file.filename,
            originalName: file.originalname,
            size: file.size,
            path: file.path,
            url: `http://localhost:5001/uploads/${file.filename}`
        }));
        res.json({
            success: true,
            message: 'Файлы успешно загружены',
            data: files,
            count: files.length
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка загрузки файлов',
            error: error.message
        });
    }
});
// Удалить файл
router.delete('/files/:filename', (req, res) => {
    try {
        const filename = req.params.filename;
        const filePath = path_1.default.join('uploads', filename);
        if (!fs_1.default.existsSync(filePath)) {
            return res.status(404).json({
                success: false,
                message: 'Файл не найден'
            });
        }
        fs_1.default.unlinkSync(filePath);
        res.json({
            success: true,
            message: 'Файл успешно удален'
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: 'Ошибка удаления файла',
            error: error.message
        });
    }
});
exports.default = router;
