const http = require('http');
const url = require('url');

const PORT = 3001;

// Mock data
const mockData = {
  '/api/restaurants': [
    { _id: '1', name: 'БЫК Москва', city: 'Москва', cityId: '1', cityName: 'Москва', brandId: '1', brandName: 'БЫК', rating: 4.5, status: 'active', description: 'Фирменный ресторан в центре Москвы', address: 'ул. Тверская, 1', phone: '+7 (495) 123-45-67', email: 'moscow@byk.ru', workingHours: '10:00 - 23:00', photos: ['photo1.jpg', 'photo2.jpg'], videos: ['video1.mp4'], isActive: true, createdAt: '2024-01-01', revenue: 150000 },
    { _id: '2', name: 'БЫК СПб', city: 'СПб', cityId: '2', cityName: 'СПб', brandId: '1', brandName: 'БЫК', rating: 4.2, status: 'active', description: 'Ресторан в историческом центре Петербурга', address: 'Невский проспект, 28', phone: '+7 (812) 234-56-78', email: 'spb@byk.ru', workingHours: '10:00 - 24:00', photos: ['photo3.jpg', 'photo4.jpg'], videos: ['video2.mp4'], isActive: true, createdAt: '2024-01-02', revenue: 120000 },
    { _id: '3', name: 'БЫК Казань', city: 'Казань', cityId: '3', cityName: 'Казань', brandId: '1', brandName: 'БЫК', rating: 4.8, status: 'active', description: 'Современный ресторан в Казани', address: 'ул. Баумана, 44', phone: '+7 (843) 345-67-89', email: 'kazan@byk.ru', workingHours: '11:00 - 23:00', photos: ['photo5.jpg', 'photo6.jpg'], videos: ['video3.mp4'], isActive: true, createdAt: '2024-01-03', revenue: 180000 },
    { _id: '4', name: 'БЫК Екатеринбург', city: 'Екатеринбург', cityId: '4', cityName: 'Екатеринбург', brandId: '1', brandName: 'БЫК', rating: 4.3, status: 'active', description: 'Ресторан в центре Екатеринбурга', address: 'пр. Ленина, 5', phone: '+7 (343) 456-78-90', email: 'ekb@byk.ru', workingHours: '10:00 - 22:00', photos: ['photo7.jpg'], videos: [], isActive: true, createdAt: '2024-01-04', revenue: 95000 },
    { _id: '5', name: 'БЫК Новосибирск', city: 'Новосибирск', cityId: '5', cityName: 'Новосибирск', brandId: '1', brandName: 'БЫК', rating: 4.1, status: 'active', description: 'Ресторан в Новосибирске', address: 'ул. Красный проспект, 25', phone: '+7 (383) 567-89-01', email: 'nsk@byk.ru', workingHours: '10:00 - 23:00', photos: ['photo8.jpg', 'photo9.jpg'], videos: ['video4.mp4'], isActive: true, createdAt: '2024-01-05', revenue: 110000 }
  ],
  '/api/dishes': [
    { _id: '1', name: 'Стейк Рибай', description: 'Нежный стейк из говядины с картофелем фри', price: 2500, restaurantId: '1', restaurantName: 'БЫК Москва', restaurantBrand: 'БЫК', categoryId: '1', categoryName: 'Основные', imageURL: 'steak.jpg', isAvailable: true, preparationTime: 25, calories: 650, allergens: ['глютен', 'молоко'], ingredients: ['говядина', 'картофель', 'специи'], createdAt: '2024-01-01' },
    { _id: '2', name: 'Цезарь с курицей', description: 'Классический салат Цезарь с куриной грудкой', price: 890, restaurantId: '1', restaurantName: 'БЫК Москва', restaurantBrand: 'БЫК', categoryId: '2', categoryName: 'Закуски', imageURL: 'caesar.jpg', isAvailable: true, preparationTime: 15, calories: 320, allergens: ['яйца', 'глютен'], ingredients: ['курица', 'салат', 'пармезан', 'сухарики'], createdAt: '2024-01-01' },
    { _id: '3', name: 'Тирамису', description: 'Итальянский десерт с кофе и маскарпоне', price: 650, restaurantId: '2', restaurantName: 'БЫК СПб', restaurantBrand: 'БЫК', categoryId: '3', categoryName: 'Десерты', imageURL: 'tiramisu.jpg', isAvailable: true, preparationTime: 10, calories: 420, allergens: ['яйца', 'молоко', 'глютен'], ingredients: ['маскарпоне', 'кофе', 'какао', 'печенье'], createdAt: '2024-01-02' },
    { _id: '4', name: 'Бургер БЫК', description: 'Фирменный бургер с говядиной и овощами', price: 1200, restaurantId: '3', restaurantName: 'БЫК Казань', restaurantBrand: 'БЫК', categoryId: '1', categoryName: 'Основные', imageURL: 'burger.jpg', isAvailable: true, preparationTime: 20, calories: 780, allergens: ['глютен', 'молоко'], ingredients: ['говядина', 'булочка', 'салат', 'помидор', 'лук'], createdAt: '2024-01-03' },
    { _id: '5', name: 'Лосось на гриле', description: 'Лосось с овощами и рисом', price: 1800, restaurantId: '4', restaurantName: 'БЫК Екатеринбург', restaurantBrand: 'БЫК', categoryId: '1', categoryName: 'Основные', imageURL: 'salmon.jpg', isAvailable: true, preparationTime: 30, calories: 520, allergens: ['рыба'], ingredients: ['лосось', 'рис', 'овощи', 'лимон'], createdAt: '2024-01-04' },
    { _id: '6', name: 'Шоколадный фондан', description: 'Горячий шоколадный кекс с мороженым', price: 750, restaurantId: '5', restaurantName: 'БЫК Новосибирск', restaurantBrand: 'БЫК', categoryId: '3', categoryName: 'Десерты', imageURL: 'fondant.jpg', isAvailable: true, preparationTime: 15, calories: 580, allergens: ['яйца', 'молоко', 'глютен'], ingredients: ['шоколад', 'яйца', 'мука', 'мороженое'], createdAt: '2024-01-05' }
  ],
  '/api/news': [
    { _id: '1', title: 'Новое меню в БЫК Москва', content: 'Мы рады представить обновленное меню с новыми блюдами от нашего шеф-повара. Попробуйте наши фирменные стейки и десерты!', author: 'Администратор', imageURL: 'menu.jpg', videoURL: 'menu-video.mp4', category: 'Меню', tags: ['меню', 'новинки', 'стейки'], isPublished: true, publishedAt: '2024-01-15', views: 1250, likes: 89, createdAt: '2024-01-15' },
    { _id: '2', title: 'Акция: Скидка 20% на все блюда', content: 'Специальное предложение для наших гостей! Скидка 20% на все блюда при заказе от 2000 рублей. Акция действует до конца месяца.', author: 'Маркетинг', imageURL: 'discount.jpg', category: 'Акции', tags: ['скидка', 'акция', 'предложение'], isPublished: true, publishedAt: '2024-01-16', views: 2100, likes: 156, createdAt: '2024-01-16' },
    { _id: '3', title: 'Открытие нового ресторана в Казани', content: 'Мы рады сообщить об открытии нового ресторана БЫК в Казани! Современный интерьер, вкусная еда и отличный сервис ждут вас.', author: 'Пресс-служба', imageURL: 'kazan-opening.jpg', videoURL: 'kazan-video.mp4', category: 'Новости', tags: ['открытие', 'казань', 'новый ресторан'], isPublished: true, publishedAt: '2024-01-17', views: 3200, likes: 234, createdAt: '2024-01-17' },
    { _id: '4', title: 'Мастер-класс по приготовлению стейков', content: 'Приглашаем всех желающих на мастер-класс по приготовлению идеального стейка. Наш шеф-повар поделится секретами приготовления.', author: 'Шеф-повар', imageURL: 'masterclass.jpg', category: 'События', tags: ['мастер-класс', 'стейки', 'обучение'], isPublished: false, publishedAt: '', views: 0, likes: 0, createdAt: '2024-01-18' },
    { _id: '5', title: 'Новая доставка в Екатеринбурге', content: 'Теперь мы доставляем блюда по всему Екатеринбургу! Быстрая доставка в течение 30 минут. Заказывайте через наше приложение.', author: 'Служба доставки', imageURL: 'delivery.jpg', category: 'Доставка', tags: ['доставка', 'екатеринбург', 'быстро'], isPublished: true, publishedAt: '2024-01-19', views: 1800, likes: 98, createdAt: '2024-01-19' }
  ],
  '/api/reservations': [
    { _id: '1', reservationNumber: 'RES001', userId: '1', userName: 'Иван Петров', restaurantId: '1', restaurantName: 'БЫК Москва', date: '2024-01-20', time: '19:00', guests: 4, status: 'confirmed', specialRequests: 'Стол у окна', createdAt: '2024-01-15', updatedAt: '2024-01-15' },
    { _id: '2', reservationNumber: 'RES002', userId: '2', userName: 'Анна Сидорова', restaurantId: '2', restaurantName: 'БЫК СПб', date: '2024-01-21', time: '18:30', guests: 2, status: 'pending', specialRequests: '', createdAt: '2024-01-16', updatedAt: '2024-01-16' },
    { _id: '3', reservationNumber: 'RES003', userId: '3', userName: 'Михаил Козлов', restaurantId: '3', restaurantName: 'БЫК Казань', date: '2024-01-22', time: '20:00', guests: 6, status: 'confirmed', specialRequests: 'День рождения', createdAt: '2024-01-17', updatedAt: '2024-01-17' },
    { _id: '4', reservationNumber: 'RES004', userId: '4', userName: 'Елена Волкова', restaurantId: '1', restaurantName: 'БЫК Москва', date: '2024-01-23', time: '19:30', guests: 3, status: 'cancelled', specialRequests: '', createdAt: '2024-01-18', updatedAt: '2024-01-18' },
    { _id: '5', reservationNumber: 'RES005', userId: '5', userName: 'Дмитрий Морозов', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', date: '2024-01-24', time: '18:00', guests: 8, status: 'confirmed', specialRequests: 'Корпоратив', createdAt: '2024-01-19', updatedAt: '2024-01-19' }
  ],
  '/api/brands': [
    { _id: '1', name: 'БЫК', description: 'Сеть премиальных ресторанов стейк-хаусов', logo: 'byk-logo.png', color: '#8B4513', isActive: true, createdAt: '2024-01-01', updatedAt: '2024-01-01' },
    { _id: '2', name: 'БЫК Premium', description: 'Премиальная линейка ресторанов', logo: 'byk-premium-logo.png', color: '#DAA520', isActive: true, createdAt: '2024-01-02', updatedAt: '2024-01-02' },
    { _id: '3', name: 'БЫК Express', description: 'Быстрое обслуживание и доставка', logo: 'byk-express-logo.png', color: '#FF6347', isActive: true, createdAt: '2024-01-03', updatedAt: '2024-01-03' }
  ],
  '/api/cities': [
    { _id: '1', name: 'Москва', population: 12000000, country: 'Россия', timezone: 'Europe/Moscow', isActive: true, createdAt: '2024-01-01', updatedAt: '2024-01-01' },
    { _id: '2', name: 'СПб', population: 5000000, country: 'Россия', timezone: 'Europe/Moscow', isActive: true, createdAt: '2024-01-02', updatedAt: '2024-01-02' },
    { _id: '3', name: 'Казань', population: 1200000, country: 'Россия', timezone: 'Europe/Moscow', isActive: true, createdAt: '2024-01-03', updatedAt: '2024-01-03' },
    { _id: '4', name: 'Екатеринбург', population: 1500000, country: 'Россия', timezone: 'Asia/Yekaterinburg', isActive: true, createdAt: '2024-01-04', updatedAt: '2024-01-04' },
    { _id: '5', name: 'Новосибирск', population: 1600000, country: 'Россия', timezone: 'Asia/Novosibirsk', isActive: true, createdAt: '2024-01-05', updatedAt: '2024-01-05' }
  ],
  '/api/categories': [
    { _id: '1', name: 'Основные', description: 'Основные блюда и стейки', brandId: '1', brandName: 'БЫК', order: 1, isActive: true, createdAt: '2024-01-01', updatedAt: '2024-01-01' },
    { _id: '2', name: 'Закуски', description: 'Закуски и салаты', brandId: '1', brandName: 'БЫК', order: 2, isActive: true, createdAt: '2024-01-02', updatedAt: '2024-01-02' },
    { _id: '3', name: 'Десерты', description: 'Десерты и сладости', brandId: '1', brandName: 'БЫК', order: 3, isActive: true, createdAt: '2024-01-03', updatedAt: '2024-01-03' },
    { _id: '4', name: 'Напитки', description: 'Напитки и коктейли', brandId: '1', brandName: 'БЫК', order: 4, isActive: true, createdAt: '2024-01-04', updatedAt: '2024-01-04' },
    { _id: '5', name: 'Супы', description: 'Первые блюда', brandId: '1', brandName: 'БЫК', order: 5, isActive: true, createdAt: '2024-01-05', updatedAt: '2024-01-05' }
  ],
  '/api/admin/restaurants': [
    { _id: '1', name: 'БЫК Москва', city: 'Москва', cityId: '1', cityName: 'Москва', brandId: '1', brandName: 'БЫК', rating: 4.5, status: 'active', revenue: 150000, orders: 245, createdAt: '2024-01-01' },
    { _id: '2', name: 'БЫК СПб', city: 'СПб', cityId: '2', cityName: 'СПб', brandId: '1', brandName: 'БЫК', rating: 4.2, status: 'active', revenue: 120000, orders: 198, createdAt: '2024-01-02' },
    { _id: '3', name: 'БЫК Казань', city: 'Казань', cityId: '3', cityName: 'Казань', brandId: '1', brandName: 'БЫК', rating: 4.8, status: 'active', revenue: 180000, orders: 312, createdAt: '2024-01-03' },
    { _id: '4', name: 'БЫК Екатеринбург', city: 'Екатеринбург', cityId: '4', cityName: 'Екатеринбург', brandId: '1', brandName: 'БЫК', rating: 4.3, status: 'active', revenue: 95000, orders: 156, createdAt: '2024-01-04' },
    { _id: '5', name: 'БЫК Новосибирск', city: 'Новосибирск', cityId: '5', cityName: 'Новосибирск', brandId: '1', brandName: 'БЫК', rating: 4.1, status: 'active', revenue: 110000, orders: 189, createdAt: '2024-01-05' }
  ],
  '/api/admin/news': [
    { _id: '1', title: 'Новое меню в БЫК Москва', content: 'Мы рады представить обновленное меню с новыми блюдами от нашего шеф-повара. Попробуйте наши фирменные стейки и десерты!', author: 'Администратор', imageURL: 'menu.jpg', videoURL: 'menu-video.mp4', category: 'Меню', tags: ['меню', 'новинки', 'стейки'], isPublished: true, publishedAt: '2024-01-15', views: 1250, likes: 89, createdAt: '2024-01-15' },
    { _id: '2', title: 'Акция: Скидка 20% на все блюда', content: 'Специальное предложение для наших гостей! Скидка 20% на все блюда при заказе от 2000 рублей. Акция действует до конца месяца.', author: 'Маркетинг', imageURL: 'discount.jpg', category: 'Акции', tags: ['скидка', 'акция', 'предложение'], isPublished: true, publishedAt: '2024-01-16', views: 2100, likes: 156, createdAt: '2024-01-16' },
    { _id: '3', title: 'Открытие нового ресторана в Казани', content: 'Мы рады сообщить об открытии нового ресторана БЫК в Казани! Современный интерьер, вкусная еда и отличный сервис ждут вас.', author: 'Пресс-служба', imageURL: 'kazan-opening.jpg', videoURL: 'kazan-video.mp4', category: 'Новости', tags: ['открытие', 'казань', 'новый ресторан'], isPublished: true, publishedAt: '2024-01-17', views: 3200, likes: 234, createdAt: '2024-01-17' },
    { _id: '4', title: 'Мастер-класс по приготовлению стейков', content: 'Приглашаем всех желающих на мастер-класс по приготовлению идеального стейка. Наш шеф-повар поделится секретами приготовления.', author: 'Шеф-повар', imageURL: 'masterclass.jpg', category: 'События', tags: ['мастер-класс', 'стейки', 'обучение'], isPublished: false, publishedAt: '', views: 0, likes: 0, createdAt: '2024-01-18' },
    { _id: '5', title: 'Новая доставка в Екатеринбурге', content: 'Теперь мы доставляем блюда по всему Екатеринбургу! Быстрая доставка в течение 30 минут. Заказывайте через наше приложение.', author: 'Служба доставки', imageURL: 'delivery.jpg', category: 'Доставка', tags: ['доставка', 'екатеринбург', 'быстро'], isPublished: true, publishedAt: '2024-01-19', views: 1800, likes: 98, createdAt: '2024-01-19' },
    { _id: '6', title: 'Сезонное меню: Летние новинки', content: 'Попробуйте наши новые летние блюда! Свежие салаты, холодные супы и освежающие напитки. Идеально для жаркой погоды.', author: 'Шеф-повар', imageURL: 'summer-menu.jpg', category: 'Меню', tags: ['лето', 'салаты', 'освежающие'], isPublished: true, publishedAt: '2024-01-20', views: 950, likes: 67, createdAt: '2024-01-20' },
    { _id: '7', title: 'БЫК СПб: Реконструкция завершена', content: 'Ресторан БЫК в Санкт-Петербурге открылся после реконструкции. Новый дизайн, расширенное меню и улучшенный сервис!', author: 'Пресс-служба', imageURL: 'spb-renovation.jpg', category: 'Новости', tags: ['реконструкция', 'спб', 'новый дизайн'], isPublished: true, publishedAt: '2024-01-21', views: 2800, likes: 189, createdAt: '2024-01-21' },
    { _id: '8', title: 'Винная карта: Новые сорта', content: 'Дополнили нашу винную карту новыми сортами из лучших виноделен России и Европы. Сомелье поможет с выбором.', author: 'Сомелье', imageURL: 'wine-card.jpg', category: 'Меню', tags: ['вина', 'сомелье', 'новые сорта'], isPublished: true, publishedAt: '2024-01-22', views: 1200, likes: 78, createdAt: '2024-01-22' },
    { _id: '9', title: 'День рождения БЫК: 5 лет', content: '5 лет назад мы открыли первый ресторан БЫК! Спасибо всем нашим гостям за доверие. Специальные предложения весь месяц!', author: 'Маркетинг', imageURL: 'birthday.jpg', category: 'События', tags: ['день рождения', '5 лет', 'предложения'], isPublished: true, publishedAt: '2024-01-23', views: 4500, likes: 312, createdAt: '2024-01-23' },
    { _id: '10', title: 'Экологическая ответственность', content: 'БЫК заботится об экологии: используем только местные продукты, сокращаем отходы и переходим на биоразлагаемую упаковку.', author: 'Устойчивое развитие', imageURL: 'ecology.jpg', category: 'О компании', tags: ['экология', 'устойчивое развитие', 'местные продукты'], isPublished: false, publishedAt: '', views: 0, likes: 0, createdAt: '2024-01-24' }
  ],
  '/api/admin/users': [
    { _id: '1', username: 'admin', fullName: 'Администратор Системы', email: 'admin@byk.ru', phone: '+7 (495) 123-45-67', role: 'admin', membershipLevel: 'Premium', loyaltyPoints: 5000, createdAt: '2024-01-01', updatedAt: '2024-01-20', lastLogin: '2024-01-20', isActive: true },
    { _id: '2', username: 'ivan_petrov', fullName: 'Иван Петров', email: 'ivan@example.com', phone: '+7 (926) 111-22-33', role: 'user', membershipLevel: 'Gold', loyaltyPoints: 2500, createdAt: '2024-01-05', updatedAt: '2024-01-19', lastLogin: '2024-01-19', isActive: true },
    { _id: '3', username: 'anna_sidorova', fullName: 'Анна Сидорова', email: 'anna@example.com', phone: '+7 (926) 222-33-44', role: 'user', membershipLevel: 'Silver', loyaltyPoints: 1200, createdAt: '2024-01-10', updatedAt: '2024-01-18', lastLogin: '2024-01-18', isActive: true },
    { _id: '4', username: 'mikhail_kozlov', fullName: 'Михаил Козлов', email: 'mikhail@example.com', phone: '+7 (926) 333-44-55', role: 'user', membershipLevel: 'Bronze', loyaltyPoints: 800, createdAt: '2024-01-12', updatedAt: '2024-01-17', lastLogin: '2024-01-17', isActive: true },
    { _id: '5', username: 'elena_volkova', fullName: 'Елена Волкова', email: 'elena@example.com', phone: '+7 (926) 444-55-66', role: 'user', membershipLevel: 'Regular', loyaltyPoints: 300, createdAt: '2024-01-15', updatedAt: '2024-01-16', lastLogin: '2024-01-16', isActive: false },
    { _id: '6', username: 'alexey_smirnov', fullName: 'Алексей Смирнов', email: 'alexey@example.com', phone: '+7 (926) 555-66-77', role: 'user', membershipLevel: 'Gold', loyaltyPoints: 3200, createdAt: '2024-01-08', updatedAt: '2024-01-20', lastLogin: '2024-01-20', isActive: true },
    { _id: '7', username: 'maria_kuznetsova', fullName: 'Мария Кузнецова', email: 'maria@example.com', phone: '+7 (926) 666-77-88', role: 'user', membershipLevel: 'Silver', loyaltyPoints: 1800, createdAt: '2024-01-11', updatedAt: '2024-01-21', lastLogin: '2024-01-21', isActive: true },
    { _id: '8', username: 'sergey_popov', fullName: 'Сергей Попов', email: 'sergey@example.com', phone: '+7 (926) 777-88-99', role: 'user', membershipLevel: 'Premium', loyaltyPoints: 4500, createdAt: '2024-01-13', updatedAt: '2024-01-22', lastLogin: '2024-01-22', isActive: true },
    { _id: '9', username: 'olga_vasileva', fullName: 'Ольга Васильева', email: 'olga@example.com', phone: '+7 (926) 888-99-00', role: 'user', membershipLevel: 'Bronze', loyaltyPoints: 950, createdAt: '2024-01-14', updatedAt: '2024-01-23', lastLogin: '2024-01-23', isActive: true },
    { _id: '10', username: 'dmitry_sokolov', fullName: 'Дмитрий Соколов', email: 'dmitry@example.com', phone: '+7 (926) 999-00-11', role: 'user', membershipLevel: 'Regular', loyaltyPoints: 150, createdAt: '2024-01-16', updatedAt: '2024-01-24', lastLogin: '2024-01-24', isActive: false },
    { _id: '11', username: 'andrey_novikov', fullName: 'Андрей Новиков', email: 'andrey@example.com', phone: '+7 (926) 101-11-22', role: 'user', membershipLevel: 'Gold', loyaltyPoints: 2800, createdAt: '2024-01-17', updatedAt: '2024-01-25', lastLogin: '2024-01-25', isActive: true },
    { _id: '12', username: 'natalia_morozova', fullName: 'Наталья Морозова', email: 'natalia@example.com', phone: '+7 (926) 202-22-33', role: 'user', membershipLevel: 'Silver', loyaltyPoints: 1650, createdAt: '2024-01-18', updatedAt: '2024-01-25', lastLogin: '2024-01-25', isActive: true },
    { _id: '13', username: 'vladimir_lebedev', fullName: 'Владимир Лебедев', email: 'vladimir@example.com', phone: '+7 (926) 303-33-44', role: 'user', membershipLevel: 'Bronze', loyaltyPoints: 920, createdAt: '2024-01-19', updatedAt: '2024-01-24', lastLogin: '2024-01-24', isActive: true },
    { _id: '14', username: 'ekaterina_sokolova', fullName: 'Екатерина Соколова', email: 'ekaterina@example.com', phone: '+7 (926) 404-44-55', role: 'user', membershipLevel: 'Premium', loyaltyPoints: 5200, createdAt: '2024-01-20', updatedAt: '2024-01-26', lastLogin: '2024-01-26', isActive: true },
    { _id: '15', username: 'pavel_kozlov', fullName: 'Павел Козлов', email: 'pavel@example.com', phone: '+7 (926) 505-55-66', role: 'user', membershipLevel: 'Regular', loyaltyPoints: 400, createdAt: '2024-01-21', updatedAt: '2024-01-26', lastLogin: '2024-01-26', isActive: true },
    { _id: '16', username: 'irina_petrova', fullName: 'Ирина Петрова', email: 'irina@example.com', phone: '+7 (926) 606-66-77', role: 'user', membershipLevel: 'Gold', loyaltyPoints: 3100, createdAt: '2024-01-22', updatedAt: '2024-01-27', lastLogin: '2024-01-27', isActive: true },
    { _id: '17', username: 'maxim_volkov', fullName: 'Максим Волков', email: 'maxim@example.com', phone: '+7 (926) 707-77-88', role: 'user', membershipLevel: 'Silver', loyaltyPoints: 1400, createdAt: '2024-01-23', updatedAt: '2024-01-27', lastLogin: '2024-01-27', isActive: true },
    { _id: '18', username: 'anna_kuznetsova', fullName: 'Анна Кузнецова', email: 'anna.k@example.com', phone: '+7 (926) 808-88-99', role: 'user', membershipLevel: 'Bronze', loyaltyPoints: 750, createdAt: '2024-01-24', updatedAt: '2024-01-28', lastLogin: '2024-01-28', isActive: false },
    { _id: '19', username: 'denis_morozov', fullName: 'Денис Морозов', email: 'denis@example.com', phone: '+7 (926) 909-99-00', role: 'user', membershipLevel: 'Regular', loyaltyPoints: 250, createdAt: '2024-01-25', updatedAt: '2024-01-28', lastLogin: '2024-01-28', isActive: true },
    { _id: '20', username: 'svetlana_novikova', fullName: 'Светлана Новикова', email: 'svetlana@example.com', phone: '+7 (926) 010-00-11', role: 'user', membershipLevel: 'Premium', loyaltyPoints: 4800, createdAt: '2024-01-26', updatedAt: '2024-01-29', lastLogin: '2024-01-29', isActive: true }
  ],
  '/api/admin/orders': [
    { _id: '1', orderNumber: 'ORD001', userId: '2', userName: 'Иван Петров', restaurantId: '1', restaurantName: 'БЫК Москва', items: [{ dishName: 'Стейк Рибай', quantity: 1, price: 2500 }], totalAmount: 2500, status: 'completed', deliveryMethod: 'pickup', paymentMethod: 'card', createdAt: '2024-01-15', updatedAt: '2024-01-15' },
    { _id: '2', orderNumber: 'ORD002', userId: '3', userName: 'Анна Сидорова', restaurantId: '2', restaurantName: 'БЫК СПб', items: [{ dishName: 'Цезарь с курицей', quantity: 2, price: 890 }], totalAmount: 1780, status: 'pending', deliveryMethod: 'delivery', deliveryAddress: 'ул. Невский проспект, 100', paymentMethod: 'cash', createdAt: '2024-01-16', updatedAt: '2024-01-16' },
    { _id: '3', orderNumber: 'ORD003', userId: '4', userName: 'Михаил Козлов', restaurantId: '3', restaurantName: 'БЫК Казань', items: [{ dishName: 'Бургер БЫК', quantity: 1, price: 1200 }, { dishName: 'Тирамису', quantity: 1, price: 650 }], totalAmount: 1850, status: 'cancelled', deliveryMethod: 'pickup', paymentMethod: 'card', createdAt: '2024-01-17', updatedAt: '2024-01-17' },
    { _id: '4', orderNumber: 'ORD004', userId: '2', userName: 'Иван Петров', restaurantId: '1', restaurantName: 'БЫК Москва', items: [{ dishName: 'Лосось на гриле', quantity: 1, price: 1800 }], totalAmount: 1800, status: 'completed', deliveryMethod: 'delivery', deliveryAddress: 'ул. Тверская, 50', paymentMethod: 'card', createdAt: '2024-01-18', updatedAt: '2024-01-18' },
    { _id: '5', orderNumber: 'ORD005', userId: '5', userName: 'Елена Волкова', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', items: [{ dishName: 'Шоколадный фондан', quantity: 2, price: 750 }], totalAmount: 1500, status: 'pending', deliveryMethod: 'pickup', paymentMethod: 'cash', createdAt: '2024-01-19', updatedAt: '2024-01-19' },
    { _id: '6', orderNumber: 'ORD006', userId: '6', userName: 'Алексей Смирнов', restaurantId: '2', restaurantName: 'БЫК СПб', items: [{ dishName: 'Стейк Рибай', quantity: 2, price: 2500 }, { dishName: 'Цезарь с курицей', quantity: 1, price: 890 }], totalAmount: 5890, status: 'completed', deliveryMethod: 'delivery', deliveryAddress: 'ул. Садовая, 15', paymentMethod: 'card', createdAt: '2024-01-20', updatedAt: '2024-01-20' },
    { _id: '7', orderNumber: 'ORD007', userId: '7', userName: 'Мария Кузнецова', restaurantId: '3', restaurantName: 'БЫК Казань', items: [{ dishName: 'Бургер БЫК', quantity: 3, price: 1200 }], totalAmount: 3600, status: 'pending', deliveryMethod: 'pickup', paymentMethod: 'cash', createdAt: '2024-01-21', updatedAt: '2024-01-21' },
    { _id: '8', orderNumber: 'ORD008', userId: '8', userName: 'Сергей Попов', restaurantId: '1', restaurantName: 'БЫК Москва', items: [{ dishName: 'Лосось на гриле', quantity: 5, price: 1800 }, { dishName: 'Тирамису', quantity: 5, price: 650 }], totalAmount: 12250, status: 'completed', deliveryMethod: 'delivery', deliveryAddress: 'ул. Арбат, 20', paymentMethod: 'card', createdAt: '2024-01-22', updatedAt: '2024-01-22' },
    { _id: '9', orderNumber: 'ORD009', userId: '9', userName: 'Ольга Васильева', restaurantId: '5', restaurantName: 'БЫК Новосибирск', items: [{ dishName: 'Шоколадный фондан', quantity: 1, price: 750 }], totalAmount: 750, status: 'completed', deliveryMethod: 'pickup', paymentMethod: 'cash', createdAt: '2024-01-23', updatedAt: '2024-01-23' },
    { _id: '10', orderNumber: 'ORD010', userId: '10', userName: 'Дмитрий Соколов', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', items: [{ dishName: 'Стейк Рибай', quantity: 1, price: 2500 }, { dishName: 'Бургер БЫК', quantity: 1, price: 1200 }, { dishName: 'Цезарь с курицей', quantity: 1, price: 890 }], totalAmount: 4590, status: 'cancelled', deliveryMethod: 'delivery', deliveryAddress: 'пр. Ленина, 100', paymentMethod: 'card', createdAt: '2024-01-24', updatedAt: '2024-01-24' },
    { _id: '11', orderNumber: 'ORD011', userId: '11', userName: 'Андрей Новиков', restaurantId: '1', restaurantName: 'БЫК Москва', items: [{ dishName: 'Стейк Рибай', quantity: 1, price: 2500 }, { dishName: 'Лосось на гриле', quantity: 1, price: 1800 }], totalAmount: 4300, status: 'preparing', deliveryMethod: 'delivery', deliveryAddress: 'ул. Кузнецкий мост, 12', paymentMethod: 'card', createdAt: '2024-01-25', updatedAt: '2024-01-25' },
    { _id: '12', orderNumber: 'ORD012', userId: '12', userName: 'Наталья Морозова', restaurantId: '2', restaurantName: 'БЫК СПб', items: [{ dishName: 'Тирамису', quantity: 2, price: 650 }, { dishName: 'Шоколадный фондан', quantity: 1, price: 750 }], totalAmount: 2050, status: 'ready', deliveryMethod: 'pickup', paymentMethod: 'cash', createdAt: '2024-01-25', updatedAt: '2024-01-25' },
    { _id: '13', orderNumber: 'ORD013', userId: '13', userName: 'Владимир Лебедев', restaurantId: '3', restaurantName: 'БЫК Казань', items: [{ dishName: 'Бургер БЫК', quantity: 2, price: 1200 }, { dishName: 'Цезарь с курицей', quantity: 1, price: 890 }, { dishName: 'Тирамису', quantity: 1, price: 650 }], totalAmount: 3940, status: 'delivered', deliveryMethod: 'delivery', deliveryAddress: 'ул. Баумана, 88', paymentMethod: 'card', createdAt: '2024-01-24', updatedAt: '2024-01-24' },
    { _id: '14', orderNumber: 'ORD014', userId: '14', userName: 'Екатерина Соколова', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', items: [{ dishName: 'Лосось на гриле', quantity: 1, price: 1800 }], totalAmount: 1800, status: 'confirmed', deliveryMethod: 'pickup', paymentMethod: 'card', createdAt: '2024-01-26', updatedAt: '2024-01-26' },
    { _id: '15', orderNumber: 'ORD015', userId: '15', userName: 'Павел Козлов', restaurantId: '5', restaurantName: 'БЫК Новосибирск', items: [{ dishName: 'Стейк Рибай', quantity: 3, price: 2500 }, { dishName: 'Бургер БЫК', quantity: 2, price: 1200 }], totalAmount: 9900, status: 'pending', deliveryMethod: 'delivery', deliveryAddress: 'пр. Ленина, 45', paymentMethod: 'cash', createdAt: '2024-01-26', updatedAt: '2024-01-26' },
    { _id: '16', orderNumber: 'ORD016', userId: '16', userName: 'Ирина Петрова', restaurantId: '1', restaurantName: 'БЫК Москва', items: [{ dishName: 'Цезарь с курицей', quantity: 3, price: 890 }, { dishName: 'Шоколадный фондан', quantity: 2, price: 750 }], totalAmount: 4170, status: 'preparing', deliveryMethod: 'delivery', deliveryAddress: 'ул. Тверская, 100', paymentMethod: 'card', createdAt: '2024-01-27', updatedAt: '2024-01-27' },
    { _id: '17', orderNumber: 'ORD017', userId: '17', userName: 'Максим Волков', restaurantId: '2', restaurantName: 'БЫК СПб', items: [{ dishName: 'Тирамису', quantity: 1, price: 650 }], totalAmount: 650, status: 'ready', deliveryMethod: 'pickup', paymentMethod: 'cash', createdAt: '2024-01-27', updatedAt: '2024-01-27' },
    { _id: '18', orderNumber: 'ORD018', userId: '18', userName: 'Анна Кузнецова', restaurantId: '3', restaurantName: 'БЫК Казань', items: [{ dishName: 'Лосось на гриле', quantity: 2, price: 1800 }, { dishName: 'Стейк Рибай', quantity: 1, price: 2500 }], totalAmount: 6100, status: 'cancelled', deliveryMethod: 'delivery', deliveryAddress: 'ул. Кремлевская, 35', paymentMethod: 'card', createdAt: '2024-01-28', updatedAt: '2024-01-28' },
    { _id: '19', orderNumber: 'ORD019', userId: '19', userName: 'Денис Морозов', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', items: [{ dishName: 'Бургер БЫК', quantity: 4, price: 1200 }], totalAmount: 4800, status: 'delivered', deliveryMethod: 'pickup', paymentMethod: 'card', createdAt: '2024-01-28', updatedAt: '2024-01-28' },
    { _id: '20', orderNumber: 'ORD020', userId: '20', userName: 'Светлана Новикова', restaurantId: '5', restaurantName: 'БЫК Новосибирск', items: [{ dishName: 'Шоколадный фондан', quantity: 3, price: 750 }, { dishName: 'Тирамису', quantity: 2, price: 650 }], totalAmount: 3550, status: 'confirmed', deliveryMethod: 'delivery', deliveryAddress: 'ул. Красный проспект, 150', paymentMethod: 'cash', createdAt: '2024-01-29', updatedAt: '2024-01-29' }
  ],
  '/api/admin/reservations': [
    { _id: '1', reservationNumber: 'RES001', userId: '2', userName: 'Иван Петров', restaurantId: '1', restaurantName: 'БЫК Москва', date: '2024-01-20', time: '19:00', guests: 4, status: 'confirmed', specialRequests: 'Стол у окна', createdAt: '2024-01-15', updatedAt: '2024-01-15' },
    { _id: '2', reservationNumber: 'RES002', userId: '3', userName: 'Анна Сидорова', restaurantId: '2', restaurantName: 'БЫК СПб', date: '2024-01-21', time: '18:30', guests: 2, status: 'pending', specialRequests: '', createdAt: '2024-01-16', updatedAt: '2024-01-16' },
    { _id: '3', reservationNumber: 'RES003', userId: '4', userName: 'Михаил Козлов', restaurantId: '3', restaurantName: 'БЫК Казань', date: '2024-01-22', time: '20:00', guests: 6, status: 'confirmed', specialRequests: 'День рождения', createdAt: '2024-01-17', updatedAt: '2024-01-17' },
    { _id: '4', reservationNumber: 'RES004', userId: '5', userName: 'Елена Волкова', restaurantId: '1', restaurantName: 'БЫК Москва', date: '2024-01-23', time: '19:30', guests: 3, status: 'cancelled', specialRequests: '', createdAt: '2024-01-18', updatedAt: '2024-01-18' },
    { _id: '5', reservationNumber: 'RES005', userId: '1', userName: 'Администратор Системы', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', date: '2024-01-24', time: '18:00', guests: 8, status: 'confirmed', specialRequests: 'Корпоратив', createdAt: '2024-01-19', updatedAt: '2024-01-19' },
    { _id: '6', reservationNumber: 'RES006', userId: '6', userName: 'Алексей Смирнов', restaurantId: '2', restaurantName: 'БЫК СПб', date: '2024-01-25', time: '20:30', guests: 2, status: 'confirmed', specialRequests: 'Романтический ужин', createdAt: '2024-01-20', updatedAt: '2024-01-20' },
    { _id: '7', reservationNumber: 'RES007', userId: '7', userName: 'Мария Кузнецова', restaurantId: '3', restaurantName: 'БЫК Казань', date: '2024-01-26', time: '19:00', guests: 5, status: 'pending', specialRequests: 'Детские стульчики', createdAt: '2024-01-21', updatedAt: '2024-01-21' },
    { _id: '8', reservationNumber: 'RES008', userId: '8', userName: 'Сергей Попов', restaurantId: '1', restaurantName: 'БЫК Москва', date: '2024-01-27', time: '18:00', guests: 10, status: 'confirmed', specialRequests: 'Свадьба', createdAt: '2024-01-22', updatedAt: '2024-01-22' },
    { _id: '9', reservationNumber: 'RES009', userId: '9', userName: 'Ольга Васильева', restaurantId: '5', restaurantName: 'БЫК Новосибирск', date: '2024-01-28', time: '19:30', guests: 4, status: 'confirmed', specialRequests: 'Вегетарианское меню', createdAt: '2024-01-23', updatedAt: '2024-01-23' },
    { _id: '10', reservationNumber: 'RES010', userId: '10', userName: 'Дмитрий Соколов', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', date: '2024-01-29', time: '17:30', guests: 6, status: 'cancelled', specialRequests: '', createdAt: '2024-01-24', updatedAt: '2024-01-24' },
    { _id: '11', reservationNumber: 'RES011', userId: '11', userName: 'Андрей Новиков', restaurantId: '1', restaurantName: 'БЫК Москва', date: '2024-01-30', time: '19:30', guests: 4, status: 'confirmed', specialRequests: 'Деловая встреча', createdAt: '2024-01-25', updatedAt: '2024-01-25' },
    { _id: '12', reservationNumber: 'RES012', userId: '12', userName: 'Наталья Морозова', restaurantId: '2', restaurantName: 'БЫК СПб', date: '2024-01-31', time: '18:00', guests: 3, status: 'pending', specialRequests: 'Детское меню', createdAt: '2024-01-26', updatedAt: '2024-01-26' },
    { _id: '13', reservationNumber: 'RES013', userId: '13', userName: 'Владимир Лебедев', restaurantId: '3', restaurantName: 'БЫК Казань', date: '2024-02-01', time: '20:30', guests: 8, status: 'confirmed', specialRequests: 'Юбилей', createdAt: '2024-01-27', updatedAt: '2024-01-27' },
    { _id: '14', reservationNumber: 'RES014', userId: '14', userName: 'Екатерина Соколова', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', date: '2024-02-02', time: '17:00', guests: 2, status: 'confirmed', specialRequests: 'Романтический ужин', createdAt: '2024-01-28', updatedAt: '2024-01-28' },
    { _id: '15', reservationNumber: 'RES015', userId: '15', userName: 'Павел Козлов', restaurantId: '5', restaurantName: 'БЫК Новосибирск', date: '2024-02-03', time: '19:00', guests: 5, status: 'pending', specialRequests: 'Стол у окна', createdAt: '2024-01-29', updatedAt: '2024-01-29' },
    { _id: '16', reservationNumber: 'RES016', userId: '16', userName: 'Ирина Петрова', restaurantId: '1', restaurantName: 'БЫК Москва', date: '2024-02-04', time: '18:30', guests: 6, status: 'confirmed', specialRequests: 'День рождения ребенка', createdAt: '2024-01-30', updatedAt: '2024-01-30' },
    { _id: '17', reservationNumber: 'RES017', userId: '17', userName: 'Максим Волков', restaurantId: '2', restaurantName: 'БЫК СПб', date: '2024-02-05', time: '19:30', guests: 4, status: 'cancelled', specialRequests: '', createdAt: '2024-01-31', updatedAt: '2024-01-31' },
    { _id: '18', reservationNumber: 'RES018', userId: '18', userName: 'Анна Кузнецова', restaurantId: '3', restaurantName: 'БЫК Казань', date: '2024-02-06', time: '20:00', guests: 3, status: 'confirmed', specialRequests: 'Вегетарианское меню', createdAt: '2024-02-01', updatedAt: '2024-02-01' },
    { _id: '19', reservationNumber: 'RES019', userId: '19', userName: 'Денис Морозов', restaurantId: '4', restaurantName: 'БЫК Екатеринбург', date: '2024-02-07', time: '17:30', guests: 2, status: 'pending', specialRequests: '', createdAt: '2024-02-02', updatedAt: '2024-02-02' },
    { _id: '20', reservationNumber: 'RES020', userId: '20', userName: 'Светлана Новикова', restaurantId: '5', restaurantName: 'БЫК Новосибирск', date: '2024-02-08', time: '18:00', guests: 7, status: 'confirmed', specialRequests: 'Корпоративный ужин', createdAt: '2024-02-03', updatedAt: '2024-02-03' }
  ],
  '/api/upload/files': [
    { filename: 'steak-photo.jpg', originalName: 'Стейк Рибай', url: 'https://via.placeholder.com/300x200/8B4513/FFFFFF?text=Steak', size: 1024000, uploadDate: '2024-01-15', type: 'image/jpeg' },
    { filename: 'caesar-salad.jpg', originalName: 'Цезарь с курицей', url: 'https://via.placeholder.com/300x200/90EE90/FFFFFF?text=Caesar', size: 850000, uploadDate: '2024-01-15', type: 'image/jpeg' },
    { filename: 'tiramisu-dessert.jpg', originalName: 'Тирамису', url: 'https://via.placeholder.com/300x200/D2691E/FFFFFF?text=Tiramisu', size: 950000, uploadDate: '2024-01-16', type: 'image/jpeg' },
    { filename: 'burger-photo.jpg', originalName: 'Бургер БЫК', url: 'https://via.placeholder.com/300x200/FF6347/FFFFFF?text=Burger', size: 1200000, uploadDate: '2024-01-16', type: 'image/jpeg' },
    { filename: 'salmon-grill.jpg', originalName: 'Лосось на гриле', url: 'https://via.placeholder.com/300x200/FF7F50/FFFFFF?text=Salmon', size: 1100000, uploadDate: '2024-01-17', type: 'image/jpeg' },
    { filename: 'chocolate-fondant.jpg', originalName: 'Шоколадный фондан', url: 'https://via.placeholder.com/300x200/8B4513/FFFFFF?text=Fondant', size: 900000, uploadDate: '2024-01-17', type: 'image/jpeg' },
    { filename: 'restaurant-interior.jpg', originalName: 'Интерьер ресторана', url: 'https://via.placeholder.com/300x200/696969/FFFFFF?text=Interior', size: 1500000, uploadDate: '2024-01-18', type: 'image/jpeg' },
    { filename: 'menu-presentation.mp4', originalName: 'Презентация меню', url: 'https://www.w3schools.com/html/mov_bbb.mp4', size: 5000000, uploadDate: '2024-01-18', type: 'video/mp4' },
    { filename: 'chef-cooking.mp4', originalName: 'Шеф готовит', url: 'https://www.w3schools.com/html/mov_bbb.mp4', size: 7500000, uploadDate: '2024-01-19', type: 'video/mp4' },
    { filename: 'restaurant-logo.png', originalName: 'Логотип БЫК', url: 'https://via.placeholder.com/200x100/8B4513/FFFFFF?text=BYk', size: 500000, uploadDate: '2024-01-19', type: 'image/png' }
  ],
  '/api/stats': {
    restaurants: 5,
    dishes: 6,
    news: 10,
    users: 20,
    totalRevenue: 655000,
    activeOrders: 8,
    totalReservations: 20,
    totalOrders: 20
  },
  '/api/users': [
    { _id: '1', username: 'admin', fullName: 'Администратор Системы', email: 'admin@byk.ru', phone: '+7 (495) 123-45-67', role: 'admin', membershipLevel: 'Premium', loyaltyPoints: 5000, createdAt: '2024-01-01', updatedAt: '2024-01-20', lastLogin: '2024-01-20', isActive: true },
    { _id: '2', username: 'ivan_petrov', fullName: 'Иван Петров', email: 'ivan@example.com', phone: '+7 (926) 111-22-33', role: 'user', membershipLevel: 'Gold', loyaltyPoints: 2500, createdAt: '2024-01-05', updatedAt: '2024-01-19', lastLogin: '2024-01-19', isActive: true },
    { _id: '3', username: 'anna_sidorova', fullName: 'Анна Сидорова', email: 'anna@example.com', phone: '+7 (926) 222-33-44', role: 'user', membershipLevel: 'Silver', loyaltyPoints: 1200, createdAt: '2024-01-10', updatedAt: '2024-01-18', lastLogin: '2024-01-18', isActive: true },
    { _id: '4', username: 'mikhail_kozlov', fullName: 'Михаил Козлов', email: 'mikhail@example.com', phone: '+7 (926) 333-44-55', role: 'user', membershipLevel: 'Bronze', loyaltyPoints: 800, createdAt: '2024-01-12', updatedAt: '2024-01-17', lastLogin: '2024-01-17', isActive: true },
    { _id: '5', username: 'elena_volkova', fullName: 'Елена Волкова', email: 'elena@example.com', phone: '+7 (926) 444-55-66', role: 'user', membershipLevel: 'Regular', loyaltyPoints: 300, createdAt: '2024-01-15', updatedAt: '2024-01-16', lastLogin: '2024-01-16', isActive: false }
  ]
};

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;

  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Handle PUT requests for updating orders
  if (req.method === 'PUT' && path.startsWith('/api/orders/')) {
    const orderId = path.split('/')[3];
    let body = '';
    
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const updateData = JSON.parse(body);
        
        // Find and update the order
        const orders = mockData['/api/admin/orders'] || [];
        const orderIndex = orders.findIndex(order => order._id === orderId);
        
        if (orderIndex !== -1) {
          // Update the order
          const updatedOrder = {
            ...orders[orderIndex],
            ...updateData,
            updatedAt: new Date().toISOString()
          };
          orders[orderIndex] = updatedOrder;
          
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(updatedOrder));
        } else {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Order not found' }));
        }
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON' }));
      }
    });
    return;
  }

  // Get mock data for the path
  const data = mockData[path];
  
  if (data) {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(data, null, 2));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, () => {
  console.log(`Mock server running on http://localhost:${PORT}`);
  console.log(`Available endpoints:`);
  Object.keys(mockData).forEach(endpoint => {
    console.log(`  - http://localhost:${PORT}${endpoint}`);
  });
});
