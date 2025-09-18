import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Отключаем source maps в development для избежания предупреждений
  productionBrowserSourceMaps: false,
  
  // Настройки для разработки
  experimental: {
    // Отключаем турбо режим для стабильности
    turbo: {
      rules: {
        '*.svg': {
          loaders: ['@svgr/webpack'],
          as: '*.js',
        },
      },
    },
  },
  
  // Настройки webpack
  webpack: (config, { dev, isServer }) => {
    if (dev && !isServer) {
      // Отключаем source maps в development
      config.devtool = false;
    }
    return config;
  },
};

export default nextConfig;
