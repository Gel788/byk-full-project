import { useState, useEffect } from 'react';
import { brandsApi } from '../api';

interface Brand {
  id: string;
  name: string;
  description: string;
  logo: string;
  color: string;
  isActive: boolean;
}

export const useBrands = () => {
  const [brands, setBrands] = useState<Brand[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchBrands = async () => {
    try {
      setIsLoading(true);
      setError(null);
      const serverData = await brandsApi.getAll();
      
      // Преобразуем данные сервера в нужный формат
      const adaptedBrands: Brand[] = serverData
        .filter((brand: any) => brand.isActive) // Только активные бренды
        .map((brand: any) => ({
          id: brand._id,
          name: brand.name,
          description: brand.description || '',
          logo: brand.logo || '',
          color: brand.color || '#000000',
          isActive: brand.isActive
        }));

      setBrands(adaptedBrands);
    } catch (err) {
      console.error('Error fetching brands:', err);
      setError(err instanceof Error ? err.message : 'Ошибка загрузки брендов');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchBrands();
  }, []);

  const refetch = () => {
    fetchBrands();
  };

  return {
    brands,
    isLoading,
    error,
    refetch,
  };
};
