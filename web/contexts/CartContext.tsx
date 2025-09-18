'use client';

import React, { createContext, useContext, useReducer, ReactNode } from 'react';
import { Dish, Restaurant } from '../lib/data';

interface CartItem {
  dish: Dish;
  quantity: number;
  restaurant: Restaurant;
}

interface CartState {
  items: CartItem[];
}

type CartAction =
  | { type: 'ADD_ITEM'; payload: { dish: Dish; restaurant: Restaurant } }
  | { type: 'REMOVE_ITEM'; payload: { dishId: number } }
  | { type: 'UPDATE_QUANTITY'; payload: { dishId: number; quantity: number } }
  | { type: 'CLEAR_CART' };

const CartContext = createContext<{
  state: CartState;
  addToCart: (dish: Dish, restaurant: Restaurant) => void;
  removeFromCart: (dishId: number) => void;
  updateQuantity: (dishId: number, quantity: number) => void;
  clearCart: () => void;
  getItemQuantity: (dishId: number) => number;
  getTotalItems: () => number;
  getTotalPrice: () => number;
} | undefined>(undefined);

const cartReducer = (state: CartState, action: CartAction): CartState => {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existingItem = state.items.find(
        item => item.dish.id === action.payload.dish.id
      );

      if (existingItem) {
        return {
          ...state,
          items: state.items.map(item =>
            item.dish.id === action.payload.dish.id
              ? { ...item, quantity: item.quantity + 1 }
              : item
          ),
        };
      }

      return {
        ...state,
        items: [...state.items, { ...action.payload, quantity: 1 }],
      };
    }

    case 'REMOVE_ITEM': {
      return {
        ...state,
        items: state.items.filter(item => item.dish.id !== action.payload.dishId),
      };
    }

    case 'UPDATE_QUANTITY': {
      if (action.payload.quantity <= 0) {
        return {
          ...state,
          items: state.items.filter(item => item.dish.id !== action.payload.dishId),
        };
      }

      return {
        ...state,
        items: state.items.map(item =>
          item.dish.id === action.payload.dishId
            ? { ...item, quantity: action.payload.quantity }
            : item
        ),
      };
    }

    case 'CLEAR_CART': {
      return {
        ...state,
        items: [],
      };
    }

    default:
      return state;
  }
};

export function CartProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(cartReducer, { items: [] });

  const addToCart = (dish: Dish, restaurant: Restaurant) => {
    dispatch({ type: 'ADD_ITEM', payload: { dish, restaurant } });
  };

  const removeFromCart = (dishId: number) => {
    dispatch({ type: 'REMOVE_ITEM', payload: { dishId } });
  };

  const updateQuantity = (dishId: number, quantity: number) => {
    dispatch({ type: 'UPDATE_QUANTITY', payload: { dishId, quantity } });
  };

  const clearCart = () => {
    dispatch({ type: 'CLEAR_CART' });
  };

  const getItemQuantity = (dishId: number): number => {
    const item = state.items.find(item => item.dish.id === dishId);
    return item ? item.quantity : 0;
  };

  const getTotalItems = (): number => {
    return state.items.reduce((total, item) => total + item.quantity, 0);
  };

  const getTotalPrice = (): number => {
    return state.items.reduce((total, item) => total + (item.dish.price * item.quantity), 0);
  };

  return (
    <CartContext.Provider
      value={{
        state,
        addToCart,
        removeFromCart,
        updateQuantity,
        clearCart,
        getItemQuantity,
        getTotalItems,
        getTotalPrice,
      }}
    >
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