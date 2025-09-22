const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 5001;

// CORS middleware
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:3002', 'http://localhost:3003', 'http://localhost:3004', 'http://localhost:3005', 'http://localhost:3006', 'http://localhost:3007', 'http://localhost:3008', 'http://localhost:3009'],
  credentials: true
}));

app.use(express.json());

// Mock API endpoints
app.get('/api/restaurants', (req, res) => {
  res.json([
    { id: '1', name: 'Ресторан 1', city: 'Москва', rating: 4.5 },
    { id: '2', name: 'Ресторан 2', city: 'СПб', rating: 4.2 }
  ]);
});

app.get('/api/dishes', (req, res) => {
  res.json([
    { id: '1', name: 'Блюдо 1', price: 500, restaurant: 'Ресторан 1' },
    { id: '2', name: 'Блюдо 2', price: 600, restaurant: 'Ресторан 2' }
  ]);
});

app.get('/api/news', (req, res) => {
  res.json([
    { id: '1', title: 'Новость 1', content: 'Содержание новости 1' },
    { id: '2', title: 'Новость 2', content: 'Содержание новости 2' }
  ]);
});

app.get('/api/reservations', (req, res) => {
  res.json([
    { id: '1', restaurant: 'Ресторан 1', date: '2024-01-15', guests: 4 },
    { id: '2', restaurant: 'Ресторан 2', date: '2024-01-16', guests: 2 }
  ]);
});

app.get('/api/brands', (req, res) => {
  res.json([
    { id: '1', name: 'Бренд 1', description: 'Описание бренда 1' },
    { id: '2', name: 'Бренд 2', description: 'Описание бренда 2' }
  ]);
});

app.get('/api/cities', (req, res) => {
  res.json([
    { id: '1', name: 'Москва', population: 12000000 },
    { id: '2', name: 'СПб', population: 5000000 }
  ]);
});

app.get('/api/categories', (req, res) => {
  res.json([
    { id: '1', name: 'Категория 1', description: 'Описание категории 1' },
    { id: '2', name: 'Категория 2', description: 'Описание категории 2' }
  ]);
});

// Admin endpoints
app.get('/api/admin/restaurants', (req, res) => {
  res.json([
    { id: '1', name: 'Ресторан 1', city: 'Москва', rating: 4.5, status: 'active' },
    { id: '2', name: 'Ресторан 2', city: 'СПб', rating: 4.2, status: 'active' }
  ]);
});

app.get('/api/admin/news', (req, res) => {
  res.json([
    { id: '1', title: 'Новость 1', content: 'Содержание новости 1', status: 'published' },
    { id: '2', title: 'Новость 2', content: 'Содержание новости 2', status: 'draft' }
  ]);
});

app.get('/api/admin/users', (req, res) => {
  res.json([
    { id: '1', name: 'Пользователь 1', email: 'user1@example.com', role: 'user' },
    { id: '2', name: 'Пользователь 2', email: 'user2@example.com', role: 'admin' }
  ]);
});

app.get('/api/admin/orders', (req, res) => {
  res.json([
    { id: '1', user: 'Пользователь 1', total: 1500, status: 'completed' },
    { id: '2', user: 'Пользователь 2', total: 2000, status: 'pending' }
  ]);
});

app.get('/api/admin/reservations', (req, res) => {
  res.json([
    { id: '1', restaurant: 'Ресторан 1', user: 'Пользователь 1', date: '2024-01-15', guests: 4, status: 'confirmed' },
    { id: '2', restaurant: 'Ресторан 2', user: 'Пользователь 2', date: '2024-01-16', guests: 2, status: 'pending' }
  ]);
});

app.get('/api/upload/files', (req, res) => {
  res.json({
    files: [
      { name: 'image1.jpg', size: 1024000, uploadDate: '2024-01-15' },
      { name: 'image2.png', size: 2048000, uploadDate: '2024-01-16' }
    ],
    count: 2
  });
});

app.listen(PORT, () => {
  console.log(`Simple mock server running on http://localhost:${PORT}`);
  console.log(`Serving mock data for admin panel`);
});
