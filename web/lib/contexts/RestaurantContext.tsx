'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { Restaurant, Dish } from '../../types';
import { restaurants, dishes } from '../data';

interface RestaurantContextType {
  restaurants: Restaurant[];
  dishes: Dish[];
  selectedRestaurant: Restaurant | null;
  setSelectedRestaurant: (restaurant: Restaurant | null) => void;
  getDishesByRestaurant: (restaurantId: string) => Dish[];
  getRestaurantById: (id: string) => Restaurant | undefined;
  getDishById: (id: string) => Dish | undefined;
  filteredDishes: Dish[];
  setFilteredDishes: (dishes: Dish[]) => void;
  searchDishes: (query: string) => void;
  filterByCategory: (category: string) => void;
  clearFilters: () => void;
}

const RestaurantContext = createContext<RestaurantContextType | undefined>(undefined);

export function RestaurantProvider({ children }: { children: React.ReactNode }) {
  const [selectedRestaurant, setSelectedRestaurant] = useState<Restaurant | null>(null);
  const [filteredDishes, setFilteredDishes] = useState<Dish[]>(dishes);
  const [allDishes] = useState<Dish[]>(dishes);

  const getDishesByRestaurant = (restaurantId: string): Dish[] => {
    return dishes.filter(dish => dish.restaurantId === restaurantId);
  };

  const getRestaurantById = (id: string): Restaurant | undefined => {
    return restaurants.find(restaurant => restaurant.id === id);
  };

  const getDishById = (id: string): Dish | undefined => {
    return dishes.find(dish => dish.id === id);
  };

  const searchDishes = (query: string) => {
    if (!query.trim()) {
      setFilteredDishes(allDishes);
      return;
    }

    const filtered = allDishes.filter(dish =>
      dish.name.toLowerCase().includes(query.toLowerCase()) ||
      dish.description.toLowerCase().includes(query.toLowerCase()) ||
      dish.category.toLowerCase().includes(query.toLowerCase())
    );
    setFilteredDishes(filtered);
  };

  const filterByCategory = (category: string) => {
    if (category === 'all') {
      setFilteredDishes(allDishes);
      return;
    }

    const filtered = allDishes.filter(dish => dish.category === category);
    setFilteredDishes(filtered);
  };

  const clearFilters = () => {
    setFilteredDishes(allDishes);
  };

  // При изменении выбранного ресторана фильтруем блюда
  useEffect(() => {
    if (selectedRestaurant) {
      const restaurantDishes = getDishesByRestaurant(selectedRestaurant.id);
      setFilteredDishes(restaurantDishes);
    } else {
      setFilteredDishes(allDishes);
    }
  }, [selectedRestaurant, allDishes]);

  const value: RestaurantContextType = {
    restaurants,
    dishes,
    selectedRestaurant,
    setSelectedRestaurant,
    getDishesByRestaurant,
    getRestaurantById,
    getDishById,
    filteredDishes,
    setFilteredDishes,
    searchDishes,
    filterByCategory,
    clearFilters,
  };

  return (
    <RestaurantContext.Provider value={value}>
      {children}
    </RestaurantContext.Provider>
  );
}

export function useRestaurant() {
  const context = useContext(RestaurantContext);
  if (context === undefined) {
    throw new Error('useRestaurant must be used within a RestaurantProvider');
  }
  return context;
}

// Алиас для обратной совместимости
export const useRestaurants = useRestaurant; 