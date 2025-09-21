import { useState, useEffect } from 'react';
import { citiesApi } from '../api';

interface City {
  id: string;
  name: string;
  country: string;
  timezone: string;
  isActive: boolean;
}

export const useCities = () => {
  const [cities, setCities] = useState<City[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCities = async () => {
    try {
      setIsLoading(true);
      setError(null);
      const serverData = await citiesApi.getAll();
      
      // Преобразуем данные сервера в нужный формат
      const adaptedCities: City[] = serverData
        .filter((city: any) => city.isActive) // Только активные города
        .map((city: any) => ({
          id: city._id,
          name: city.name,
          country: city.country || 'Россия',
          timezone: city.timezone || 'Europe/Moscow',
          isActive: city.isActive
        }));

      setCities(adaptedCities);
    } catch (err) {
      console.error('Error fetching cities:', err);
      setError(err instanceof Error ? err.message : 'Ошибка загрузки городов');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCities();
  }, []);

  const refetch = () => {
    fetchCities();
  };

  return {
    cities,
    isLoading,
    error,
    refetch,
  };
};
