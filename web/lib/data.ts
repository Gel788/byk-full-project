import { Restaurant, Dish, News } from '../types';

export const restaurants: Restaurant[] = [
  // THE БЫК рестораны
  {
    id: '1',
    name: 'THE БЫК - Тверская',
    brand: 'theByk',
    description: 'Стейк-хаус премиум класса с лучшими мраморными стейками',
    address: 'ул. Тверская, 15',
    phone: '+7 (495) 123-45-67',
    rating: 4.8,
    deliveryTime: '30-45 мин',
    minOrder: 1500,
    image: '/images/restaurants/thebyk_main.jpg',
    logo: '/images/restaurants/thebyk_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7558, lng: 37.6176 }
  },
  {
    id: '2',
    name: 'THE БЫК - Арбат',
    brand: 'theByk',
    description: 'Элегантный стейк-хаус в историческом центре',
    address: 'ул. Арбат, 42',
    phone: '+7 (495) 234-56-78',
    rating: 4.7,
    deliveryTime: '25-40 мин',
    minOrder: 1200,
    image: '/images/restaurants/thebyk_main.jpg',
    logo: '/images/restaurants/thebyk_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7494, lng: 37.5912 }
  },
  {
    id: '3',
    name: 'THE БЫК - Кутузовский',
    brand: 'theByk',
    description: 'Премиальный стейк-хаус с панорамным видом',
    address: 'Кутузовский пр-т, 25',
    phone: '+7 (495) 345-67-89',
    rating: 4.9,
    deliveryTime: '35-50 мин',
    minOrder: 1800,
    image: '/images/restaurants/thebyk_main.jpg',
    logo: '/images/restaurants/thebyk_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7517, lng: 37.6178 }
  },
  {
    id: '4',
    name: 'THE БЫК - Покровка',
    brand: 'theByk',
    description: 'Уютный стейк-хаус в атмосферном районе',
    address: 'ул. Покровка, 18',
    phone: '+7 (495) 456-78-90',
    rating: 4.6,
    deliveryTime: '20-35 мин',
    minOrder: 1000,
    image: '/images/restaurants/thebyk_main.jpg',
    logo: '/images/restaurants/thebyk_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7539, lng: 37.6208 }
  },

  // THE ПИВО рестораны
  {
    id: '5',
    name: 'THE ПИВО - Арбат',
    brand: 'thePivo',
    description: 'Крафтовое пиво и европейская кухня',
    address: 'ул. Арбат, 25',
    phone: '+7 (495) 567-89-01',
    rating: 4.6,
    deliveryTime: '25-40 мин',
    minOrder: 800,
    image: '/images/restaurants/thepivo_main.jpg',
    logo: '/images/restaurants/thepivo_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7494, lng: 37.5912 }
  },
  {
    id: '6',
    name: 'THE ПИВО - Тверская',
    brand: 'thePivo',
    description: 'Пивной ресторан с живой музыкой',
    address: 'ул. Тверская, 8',
    phone: '+7 (495) 678-90-12',
    rating: 4.5,
    deliveryTime: '30-45 мин',
    minOrder: 900,
    image: '/images/restaurants/thepivo_main.jpg',
    logo: '/images/restaurants/thepivo_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7558, lng: 37.6176 }
  },
  {
    id: '7',
    name: 'THE ПИВО - Покровка',
    brand: 'thePivo',
    description: 'Уютный паб с крафтовым пивом',
    address: 'ул. Покровка, 12',
    phone: '+7 (495) 789-01-23',
    rating: 4.4,
    deliveryTime: '20-35 мин',
    minOrder: 700,
    image: '/images/restaurants/thepivo_main.jpg',
    logo: '/images/restaurants/thepivo_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7539, lng: 37.6208 }
  },
  {
    id: '8',
    name: 'THE ПИВО - Кутузовский',
    brand: 'thePivo',
    description: 'Современный пивной ресторан',
    address: 'Кутузовский пр-т, 35',
    phone: '+7 (495) 890-12-34',
    rating: 4.3,
    deliveryTime: '35-50 мин',
    minOrder: 850,
    image: '/images/restaurants/thepivo_main.jpg',
    logo: '/images/restaurants/thepivo_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7517, lng: 37.6178 }
  },

  // MOSCA рестораны
  {
    id: '9',
    name: 'MOSCA - Кутузовский',
    brand: 'mosca',
    description: 'Итальянская кухня и паста ручной работы',
    address: 'Кутузовский пр-т, 30',
    phone: '+7 (495) 901-23-45',
    rating: 4.7,
    deliveryTime: '35-50 мин',
    minOrder: 1200,
    image: '/images/restaurants/mosca_main.jpg',
    logo: '/images/restaurants/mosca_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7517, lng: 37.6178 }
  },
  {
    id: '10',
    name: 'MOSCA - Тверская',
    brand: 'mosca',
    description: 'Аутентичная итальянская кухня',
    address: 'ул. Тверская, 22',
    phone: '+7 (495) 012-34-56',
    rating: 4.8,
    deliveryTime: '25-40 мин',
    minOrder: 1100,
    image: '/images/restaurants/mosca_main.jpg',
    logo: '/images/restaurants/mosca_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7558, lng: 37.6176 }
  },
  {
    id: '11',
    name: 'MOSCA - Арбат',
    brand: 'mosca',
    description: 'Итальянский ресторан с террасой',
    address: 'ул. Арбат, 15',
    phone: '+7 (495) 123-45-67',
    rating: 4.6,
    deliveryTime: '30-45 мин',
    minOrder: 1000,
    image: '/images/restaurants/mosca_main.jpg',
    logo: '/images/restaurants/mosca_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7494, lng: 37.5912 }
  },
  {
    id: '12',
    name: 'MOSCA - Покровка',
    brand: 'mosca',
    description: 'Уютный итальянский ресторан',
    address: 'ул. Покровка, 28',
    phone: '+7 (495) 234-56-78',
    rating: 4.5,
    deliveryTime: '20-35 мин',
    minOrder: 950,
    image: '/images/restaurants/mosca_main.jpg',
    logo: '/images/restaurants/mosca_logo.jpg',
    isOpen: true,
    coordinates: { lat: 55.7539, lng: 37.6208 }
  }
];

export const dishes: Dish[] = [
  // Блюда для THE БЫК ресторанов
  {
    id: '1',
    name: 'Рибай стейк',
    description: 'Мраморный стейк из говядины, подается с овощами гриль',
    price: 2500,
    calories: 450,
    preparationTime: 20,
    image: '/images/dishes/ribai_steak.jpg',
    category: 'Стейки',
    isAvailable: true,
    allergens: ['Глютен'],
    restaurantId: '1'
  },
  {
    id: '2',
    name: 'Цезарь салат',
    description: 'Классический салат с куриным филе, сыром пармезан и соусом цезарь',
    price: 850,
    calories: 320,
    preparationTime: 15,
    image: '/images/dishes/caesar_salad.jpg',
    category: 'Салаты',
    isAvailable: true,
    allergens: ['Глютен', 'Лактоза'],
    restaurantId: '1'
  },
  {
    id: '3',
    name: 'Филе-миньон',
    description: 'Нежный стейк из вырезки говядины',
    price: 2800,
    calories: 380,
    preparationTime: 18,
    image: '/images/dishes/ribai_steak.jpg',
    category: 'Стейки',
    isAvailable: true,
    allergens: ['Глютен'],
    restaurantId: '2'
  },
  {
    id: '4',
    name: 'Стриплойн',
    description: 'Стейк из полоски вырезки с косточкой',
    price: 2200,
    calories: 420,
    preparationTime: 22,
    image: '/images/dishes/ribai_steak.jpg',
    category: 'Стейки',
    isAvailable: true,
    allergens: ['Глютен'],
    restaurantId: '3'
  },
  {
    id: '5',
    name: 'Томатный суп',
    description: 'Густой томатный суп с базиликом',
    price: 450,
    calories: 180,
    preparationTime: 12,
    image: '/images/dishes/caesar_salad.jpg',
    category: 'Супы',
    isAvailable: true,
    allergens: ['Глютен'],
    restaurantId: '4'
  },

  // Блюда для THE ПИВО ресторанов
  {
    id: '6',
    name: 'Сосиски с картошкой',
    description: 'Немецкие сосиски с картофельным пюре и горчицей',
    price: 550,
    calories: 420,
    preparationTime: 12,
    image: '/images/dishes/sausages.jpg',
    category: 'Горячие блюда',
    isAvailable: true,
    allergens: ['Глютен'],
    restaurantId: '5'
  },
  {
    id: '7',
    name: 'Крендель',
    description: 'Свежий крендель с солью, подается с горчицей',
    price: 180,
    calories: 150,
    preparationTime: 5,
    image: '/images/dishes/pretzel.jpg',
    category: 'Закуски',
    isAvailable: true,
    allergens: ['Глютен'],
    restaurantId: '5'
  },
  {
    id: '8',
    name: 'Брецель с сыром',
    description: 'Крендель с плавленым сыром',
    price: 220,
    calories: 200,
    preparationTime: 8,
    image: '/images/dishes/pretzel.jpg',
    category: 'Закуски',
    isAvailable: true,
    allergens: ['Глютен', 'Лактоза'],
    restaurantId: '6'
  },
  {
    id: '9',
    name: 'Картофельные дольки',
    description: 'Хрустящие картофельные дольки с соусом',
    price: 320,
    calories: 280,
    preparationTime: 15,
    image: '/images/dishes/sausages.jpg',
    category: 'Закуски',
    isAvailable: true,
    allergens: ['Глютен'],
    restaurantId: '7'
  },
  {
    id: '10',
    name: 'Свиные ребрышки',
    description: 'Свиные ребрышки в пивном соусе',
    price: 680,
    calories: 450,
    preparationTime: 25,
    image: '/images/dishes/sausages.jpg',
    category: 'Горячие блюда',
    isAvailable: true,
    allergens: ['Глютен'],
    restaurantId: '8'
  },

  // Блюда для MOSCA ресторанов
  {
    id: '11',
    name: 'Паста Карбонара',
    description: 'Спагетти с беконом, яйцом и сыром пармезан',
    price: 750,
    calories: 380,
    preparationTime: 18,
    image: '/images/dishes/pasta_carbonara.jpg',
    category: 'Паста',
    isAvailable: true,
    allergens: ['Глютен', 'Лактоза'],
    restaurantId: '9'
  },
  {
    id: '12',
    name: 'Пицца Маргарита',
    description: 'Классическая пицца с томатным соусом и моцареллой',
    price: 650,
    calories: 280,
    preparationTime: 25,
    image: '/images/dishes/pizza_margherita.jpg',
    category: 'Пицца',
    isAvailable: true,
    allergens: ['Глютен', 'Лактоза'],
    restaurantId: '9'
  },
  {
    id: '13',
    name: 'Паста Болоньезе',
    description: 'Спагетти с мясным соусом и пармезаном',
    price: 720,
    calories: 400,
    preparationTime: 20,
    image: '/images/dishes/pasta_carbonara.jpg',
    category: 'Паста',
    isAvailable: true,
    allergens: ['Глютен', 'Лактоза'],
    restaurantId: '10'
  },
  {
    id: '14',
    name: 'Пицца Пепперони',
    description: 'Пицца с пепперони и моцареллой',
    price: 780,
    calories: 320,
    preparationTime: 28,
    image: '/images/dishes/pizza_margherita.jpg',
    category: 'Пицца',
    isAvailable: true,
    allergens: ['Глютен', 'Лактоза'],
    restaurantId: '11'
  },
  {
    id: '15',
    name: 'Тирамису',
    description: 'Классический итальянский десерт',
    price: 450,
    calories: 280,
    preparationTime: 10,
    image: '/images/dishes/caesar_salad.jpg',
    category: 'Десерты',
    isAvailable: true,
    allergens: ['Глютен', 'Лактоза'],
    restaurantId: '12'
  }
];

export const news: News[] = [
  {
    id: '1',
    title: 'Новое меню в THE БЫК',
    content: 'Представляем новую коллекцию стейков из австралийской говядины',
    image: '/images/news/byk_news.jpg',
    publishedAt: new Date('2024-01-15'),
    restaurantId: '1'
  },
  {
    id: '2',
    title: 'Крафтовое пиво в THE ПИВО',
    content: 'Попробуйте новые сорта крафтового пива от лучших пивоварен',
    image: '/images/news/pivo_news.jpg',
    publishedAt: new Date('2024-01-10'),
    restaurantId: '2'
  },
  {
    id: '3',
    title: 'Итальянские вечера в MOSCA',
    content: 'Каждый четверг - специальное меню от шеф-повара',
    image: '/images/news/mosca_news.jpg',
    publishedAt: new Date('2024-01-05'),
    restaurantId: '3'
  }
];

export const getBrandColors = (brand: string) => {
  switch (brand) {
    case 'theByk':
      return {
        primary: '#8B4513',
        secondary: '#D2691E',
        accent: '#FFD700'
      };
    case 'thePivo':
      return {
        primary: '#FF6B35',
        secondary: '#F7931E',
        accent: '#FFD700'
      };
    case 'mosca':
      return {
        primary: '#2C3E50',
        secondary: '#34495E',
        accent: '#E74C3C'
      };
    default:
      return {
        primary: '#f2751e',
        secondary: '#64748b',
        accent: '#eab308'
      };
  }
}; 