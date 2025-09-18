"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const mongoose_1 = __importDefault(require("mongoose"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const morgan_1 = __importDefault(require("morgan"));
// Import routes
const users_1 = __importDefault(require("./routes/users"));
const restaurants_1 = __importDefault(require("./routes/restaurants"));
const dishes_1 = __importDefault(require("./routes/dishes"));
const news_1 = __importDefault(require("./routes/news"));
const reservation_1 = __importDefault(require("./routes/reservation"));
const orders_1 = __importDefault(require("./routes/orders"));
const upload_1 = __importDefault(require("./routes/upload"));
// Admin Routes
const adminRoutes_1 = __importDefault(require("./admin/routes/adminRoutes"));
// Load environment variables
dotenv_1.default.config();
const app = (0, express_1.default)();
// CORS for all requests
app.use((0, cors_1.default)({
    origin: ["http://localhost:3000", "http://localhost:3001"],
    credentials: true
}));
// Static files with CORS headers
app.use('/uploads', (req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    // Убираем Cross-Origin-Resource-Policy чтобы не блокировать изображения
    next();
}, express_1.default.static('uploads'));
// Middleware (helmet disabled for development)
// app.use(helmet());
app.use((0, morgan_1.default)("combined"));
app.use(express_1.default.json({ limit: "10mb" }));
app.use(express_1.default.urlencoded({ extended: true, limit: "10mb" }));
// Connect to MongoDB
mongoose_1.default
    .connect(process.env.MONGODB_URI || "mongodb://localhost:27017/byk_holding")
    .then(() => console.log("MongoDB connected"))
    .catch((err) => console.error("MongoDB connection error:", err));
// API Routes
app.use("/api/users", users_1.default);
app.use("/api/restaurants", restaurants_1.default);
app.use("/api/dishes", dishes_1.default);
app.use("/api/news", news_1.default);
app.use("/api/reservations", reservation_1.default);
app.use("/api/orders", orders_1.default);
app.use("/api/upload", upload_1.default);
// Admin Routes
app.use("/api/admin", adminRoutes_1.default);
// Health check
app.get("/", (req, res) => {
    res.json({
        message: "БЫК Backend API",
        version: "1.0.0",
        status: "running",
        timestamp: new Date().toISOString(),
    });
});
// 404 Handler
app.use((req, res) => {
    res.status(404).json({ message: "Эндпоинт не найден" });
});
// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Что-то пошло не так!');
});
const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
exports.default = app;
