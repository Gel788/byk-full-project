import { Restaurant, Dish, News } from '../types';

// Типы данных с сервера
interface ServerRestaurant {
  _id: string;
  name: string;
  brandId: {
    _id: string;
    name: string;
    logo: string;
    color: string;
  };
  cityId: {
    _id: string;
    name: string;
    country: string;
  };
  address: string;
  phone: string;
  email: string;
  description: string;
  workingHours: string;
  rating: number;
  photos: string[];
  videos: string[];
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

interface ServerDish {
  _id: string;
  name: string;
  description: string;
  price: number;
  categoryId: {
    _id: string;
    name: string;
  };
  restaurantId: {
    _id: string;
    name: string;
    brandId: {
      _id: string;
      name: string;
    };
  };
  imageURL: string;
  preparationTime: number;
  calories: number;
  allergens: string[];
  isAvailable: boolean;
  createdAt: string;
  updatedAt: string;
}

interface ServerNews {
  _id: string;
  title: string;
  content: string;
  imageURL: string;
  restaurantId?: {
    _id: string;
    name: string;
  };
  createdAt: string;
  updatedAt: string;
}

// Функция для преобразования бренда
const mapBrandName = (brandName: string): 'theByk' | 'thePivo' | 'mosca' => {
  const name = brandName.toLowerCase();
  if (name.includes('бык')) return 'theByk';
  if (name.includes('pivo')) return 'thePivo';
  if (name.includes('mosca')) return 'mosca';
  return 'theByk'; // по умолчанию
};

// Адаптер для ресторана
export const adaptRestaurant = (serverRestaurant: ServerRestaurant): Restaurant => {
  return {
    id: serverRestaurant._id,
    name: serverRestaurant.name,
    brand: mapBrandName(serverRestaurant.brandId.name),
    description: serverRestaurant.description || 'Премиальный ресторан с отличной кухней',
    address: serverRestaurant.address || `${serverRestaurant.cityId.name}`,
    phone: serverRestaurant.phone || '+7 (999) 123-45-67',
    rating: serverRestaurant.rating || 4.5,
    deliveryTime: '30-45 мин',
    minOrder: 1000,
    image: serverRestaurant.photos[0] || '/images/restaurants/default.jpg',
    logo: serverRestaurant.brandId.logo || '/images/restaurants/default-logo.jpg',
    isOpen: serverRestaurant.isActive,
    coordinates: {
      lat: 55.7558,
      lng: 37.6176
    }
  };
};

// Адаптер для блюда
export const adaptDish = (serverDish: ServerDish): Dish => {
  return {
    id: serverDish._id,
    name: serverDish.name,
    description: serverDish.description || 'Вкусное блюдо от наших поваров',
    price: serverDish.price,
    calories: serverDish.calories || 300,
    preparationTime: serverDish.preparationTime || 20,
    image: serverDish.imageURL || '/images/dishes/default.jpg',
    category: serverDish.categoryId.name,
    isAvailable: serverDish.isAvailable,
    allergens: serverDish.allergens || [],
    restaurantId: serverDish.restaurantId._id
  };
};

// Адаптер для новости
export const adaptNews = (serverNews: ServerNews): News => {
  return {
    id: serverNews._id,
    title: serverNews.title,
    content: serverNews.content,
    image: serverNews.imageURL || '/images/news/default.jpg',
    publishedAt: new Date(serverNews.createdAt),
    restaurantId: serverNews.restaurantId?._id
  };
};

// Функции для массового преобразования
export const adaptRestaurants = (serverRestaurants: ServerRestaurant[]): Restaurant[] => {
  return serverRestaurants.map(adaptRestaurant);
};

export const adaptDishes = (serverDishes: ServerDish[]): Dish[] => {
  return serverDishes.map(adaptDish);
};

export const adaptNewsArray = (serverNews: ServerNews[]): News[] => {
  return serverNews.map(adaptNews);
};
