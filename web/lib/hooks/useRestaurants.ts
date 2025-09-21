import { useState, useEffect } from 'react';
import { Restaurant } from '../../types';
import { restaurantsApi } from '../api';

export const useRestaurants = () => {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchRestaurants = async () => {
    try {
      setIsLoading(true);
      setError(null);
      const data = await restaurantsApi.getAll();
      setRestaurants(data);
    } catch (err) {
      console.error('Error fetching restaurants:', err);
      setError(err instanceof Error ? err.message : 'Ошибка загрузки ресторанов');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchRestaurants();
  }, []);

  const refetch = () => {
    fetchRestaurants();
  };

  return {
    restaurants,
    isLoading,
    error,
    refetch,
  };
};

export const useRestaurant = (id: string) => {
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchRestaurant = async () => {
    if (!id) return;
    
    try {
      setIsLoading(true);
      setError(null);
      const data = await restaurantsApi.getById(id);
      setRestaurant(data);
    } catch (err) {
      console.error('Error fetching restaurant:', err);
      setError(err instanceof Error ? err.message : 'Ошибка загрузки ресторана');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchRestaurant();
  }, [id]);

  return {
    restaurant,
    isLoading,
    error,
    refetch: fetchRestaurant,
  };
};

export const useRestaurantsByBrand = (brand: string) => {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchRestaurantsByBrand = async () => {
    if (!brand) return;
    
    try {
      setIsLoading(true);
      setError(null);
      const data = await restaurantsApi.getByBrand(brand);
      setRestaurants(data);
    } catch (err) {
      console.error('Error fetching restaurants by brand:', err);
      setError(err instanceof Error ? err.message : 'Ошибка загрузки ресторанов');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchRestaurantsByBrand();
  }, [brand]);

  return {
    restaurants,
    isLoading,
    error,
    refetch: fetchRestaurantsByBrand,
  };
};
