// Утилиты для форматирования чисел без проблем с гидратацией
export const formatPrice = (price: number): string => {
  // Используем простой способ форматирования без toLocaleString
  return price.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
};

// Функция для форматирования чисел с пробелами
export const formatNumber = (num: number): string => {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
};

// Функция для безопасного форматирования цены
export const safeFormatPrice = (price: number): string => {
  if (typeof window === 'undefined') {
    // На сервере используем простое форматирование
    return formatPrice(price);
  } else {
    // На клиенте можно использовать toLocaleString
    return price.toLocaleString();
  }
}; 