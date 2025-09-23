import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import helmet from "helmet";
import morgan from "morgan";
import path from "path";

// Import routes
import usersRouter from "./routes/users";
import restaurantsRouter from "./routes/restaurants";
import dishesRouter from "./routes/dishes";
import newsRouter from "./routes/news";
import reservationRouter from "./routes/reservation";
import ordersRouter from "./routes/orders";
import uploadRouter from "./routes/upload";
import brandsRouter from "./routes/brands";
import citiesRouter from "./routes/cities";
import categoriesRouter from "./routes/categories";
import authRouter from "./routes/auth";

// Admin Routes
import adminRouter from "./admin/routes/adminRoutes";

// Load environment variables
dotenv.config();

const app = express();

// CORS for all requests
app.use(cors({
  origin: [
    "http://localhost:3000", 
    "http://localhost:3001",
    "http://localhost:3002",
    "http://localhost:3003",
    "http://localhost:3004",
    "http://localhost:3005",
    "http://localhost:3006",
    "http://localhost:3007",
    "http://localhost:3008",
    "http://localhost:3009",
    "https://bulladmin.ru",
    "http://45.12.75.59:3000",
    "http://45.12.75.59:3001"
  ],
  credentials: true
}));

// Static files with CORS headers
app.use('/uploads', (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  // Убираем Cross-Origin-Resource-Policy чтобы не блокировать изображения
  next();
}, express.static('/var/www/uploads'));

// Middleware (helmet disabled for development)
// app.use(helmet());
app.use(morgan("combined"));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Connect to MongoDB
mongoose
  .connect(process.env.MONGODB_URI || "mongodb://localhost:27017/byk_holding")
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.error("MongoDB connection error:", err));

// API Routes
app.use("/api/auth", authRouter);
app.use("/api/users", usersRouter);
app.use("/api/restaurants", restaurantsRouter);
app.use("/api/dishes", dishesRouter);
app.use("/api/news", newsRouter);
app.use("/api/reservations", reservationRouter);
app.use("/api/orders", ordersRouter);
app.use("/api/upload", uploadRouter);
app.use("/api/brands", brandsRouter);
app.use("/api/cities", citiesRouter);
app.use("/api/categories", categoriesRouter);

// Admin Routes
app.use("/api/admin", adminRouter);

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
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).send('Что-то пошло не так!');
});

const PORT = parseInt(process.env.PORT || '5000');
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
