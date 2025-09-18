'use client';

import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { CartItem, Dish, Restaurant } from '../../types';

interface CartState {
  items: CartItem[];
  totalAmount: number;
  hasItems: boolean;
}

type CartAction =
  | { type: 'ADD_ITEM'; payload: { dish: Dish; restaurant: Restaurant } }
  | { type: 'REMOVE_ITEM'; payload: { dishId: string } }
  | { type: 'UPDATE_QUANTITY'; payload: { dishId: string; increment: boolean } }
  | { type: 'CLEAR_CART' }
  | { type: 'LOAD_CART'; payload: CartItem[] };

const initialState: CartState = {
  items: [],
  totalAmount: 0,
  hasItems: false,
};

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD_ITEM': {
      const { dish, restaurant } = action.payload;
      const existingItem = state.items.find(item => item.dish.id === dish.id);
      
      if (existingItem) {
        const updatedItems = state.items.map(item =>
          item.dish.id === dish.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
        
        return {
          ...state,
          items: updatedItems,
          totalAmount: updatedItems.reduce((sum, item) => sum + (item.dish.price * item.quantity), 0),
          hasItems: true,
        };
      } else {
        const newItem: CartItem = {
          id: `${dish.id}-${Date.now()}`,
          dish,
          quantity: 1,
          restaurantId: restaurant.id,
        };
        
        const updatedItems = [...state.items, newItem];
        
        return {
          ...state,
          items: updatedItems,
          totalAmount: updatedItems.reduce((sum, item) => sum + (item.dish.price * item.quantity), 0),
          hasItems: true,
        };
      }
    }
    
    case 'REMOVE_ITEM': {
      const { dishId } = action.payload;
      const updatedItems = state.items.filter(item => item.dish.id !== dishId);
      
      return {
        ...state,
        items: updatedItems,
        totalAmount: updatedItems.reduce((sum, item) => sum + (item.dish.price * item.quantity), 0),
        hasItems: updatedItems.length > 0,
      };
    }
    
    case 'UPDATE_QUANTITY': {
      const { dishId, increment } = action.payload;
      const updatedItems = state.items.map(item => {
        if (item.dish.id === dishId) {
          const newQuantity = increment ? item.quantity + 1 : Math.max(0, item.quantity - 1);
          return { ...item, quantity: newQuantity };
        }
        return item;
      }).filter(item => item.quantity > 0);
      
      return {
        ...state,
        items: updatedItems,
        totalAmount: updatedItems.reduce((sum, item) => sum + (item.dish.price * item.quantity), 0),
        hasItems: updatedItems.length > 0,
      };
    }
    
    case 'CLEAR_CART':
      return {
        ...state,
        items: [],
        totalAmount: 0,
        hasItems: false,
      };
    
    case 'LOAD_CART':
      return {
        ...state,
        items: action.payload,
        totalAmount: action.payload.reduce((sum, item) => sum + (item.dish.price * item.quantity), 0),
        hasItems: action.payload.length > 0,
      };
    
    default:
      return state;
  }
}

interface CartContextType extends CartState {
  addToCart: (dish: Dish, restaurant: Restaurant) => void;
  removeFromCart: (dishId: string) => void;
  updateQuantity: (dishId: string, increment: boolean) => void;
  clearCart: () => void;
  getItemQuantity: (dishId: string) => number;
  groupedCartItems: () => Array<{
    dish: Dish;
    quantity: number;
    restaurant: Restaurant;
  }>;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

export function CartProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(cartReducer, initialState);

  // Загрузка корзины из localStorage
  useEffect(() => {
    const savedCart = localStorage.getItem('byk-cart');
    if (savedCart) {
      try {
        const cartItems = JSON.parse(savedCart);
        dispatch({ type: 'LOAD_CART', payload: cartItems });
      } catch (error) {
        console.error('Error loading cart from localStorage:', error);
      }
    }
  }, []);

  // Сохранение корзины в localStorage
  useEffect(() => {
    localStorage.setItem('byk-cart', JSON.stringify(state.items));
  }, [state.items]);

  const addToCart = (dish: Dish, restaurant: Restaurant) => {
    dispatch({ type: 'ADD_ITEM', payload: { dish, restaurant } });
  };

  const removeFromCart = (dishId: string) => {
    dispatch({ type: 'REMOVE_ITEM', payload: { dishId } });
  };

  const updateQuantity = (dishId: string, increment: boolean) => {
    dispatch({ type: 'UPDATE_QUANTITY', payload: { dishId, increment } });
  };

  const clearCart = () => {
    dispatch({ type: 'CLEAR_CART' });
  };

  const getItemQuantity = (dishId: string): number => {
    const item = state.items.find(item => item.dish.id === dishId);
    return item ? item.quantity : 0;
  };

  const groupedCartItems = () => {
    const grouped = new Map<string, { dish: Dish; quantity: number; restaurant: Restaurant }>();
    
    state.items.forEach(item => {
      const key = item.dish.id;
      if (grouped.has(key)) {
        const existing = grouped.get(key)!;
        existing.quantity += item.quantity;
      } else {
        // Здесь нужно получить ресторан из данных
        grouped.set(key, {
          dish: item.dish,
          quantity: item.quantity,
          restaurant: { id: item.restaurantId } as Restaurant, // Упрощенно
        });
      }
    });
    
    return Array.from(grouped.values());
  };

  const value: CartContextType = {
    ...state,
    addToCart,
    removeFromCart,
    updateQuantity,
    clearCart,
    getItemQuantity,
    groupedCartItems,
  };

  return (
    <CartContext.Provider value={value}>
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const context = useContext(CartContext);
  if (context === undefined) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
} 