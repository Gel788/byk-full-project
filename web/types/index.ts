export interface Restaurant {
  id: string;
  name: string;
  brand: 'theByk' | 'thePivo' | 'mosca';
  description: string;
  address: string;
  phone: string;
  rating: number;
  deliveryTime: string;
  minOrder: number;
  image: string;
  logo: string;
  isOpen: boolean;
  coordinates: {
    lat: number;
    lng: number;
  };
}

export interface Dish {
  id: string;
  name: string;
  description: string;
  price: number;
  calories: number;
  preparationTime: number;
  image: string;
  category: string;
  isAvailable: boolean;
  allergens: string[];
  restaurantId: string;
}

export interface CartItem {
  id: string;
  dish: Dish;
  quantity: number;
  restaurantId: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  avatar?: string;
  password?: string;
  isVerified?: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface AuthUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  token: string;
  avatar?: string;
}

export interface LoginForm {
  email?: string;
  phone?: string;
  password: string;
}

export interface RegisterForm {
  name: string;
  email: string;
  phone: string;
  password: string;
  confirmPassword: string;
  address?: string;
}

export interface Order {
  id: string;
  userId: string;
  restaurantId: string;
  items: CartItem[];
  totalAmount: number;
  status: 'pending' | 'confirmed' | 'preparing' | 'delivering' | 'delivered' | 'cancelled';
  deliveryMethod: 'delivery' | 'pickup';
  deliveryAddress?: string;
  createdAt: Date;
  estimatedDeliveryTime?: Date;
}

export interface News {
  id: string;
  title: string;
  content: string;
  image: string;
  publishedAt: Date;
  restaurantId?: string;
}

export interface Reservation {
  id: string;
  userId: string;
  restaurantId: string;
  date: Date;
  time: string;
  guests: number;
  status: 'pending' | 'confirmed' | 'cancelled';
  specialRequests?: string;
} 