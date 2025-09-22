/** @type {import('next').NextConfig} */
const nextConfig = {
  // Отключаем Turbopack полностью
  experimental: {
    // Отключаем экспериментальные функции
    serverComponentsExternalPackages: [],
  },
  // Отключаем строгий режим для избежания проблем с модулями
  reactStrictMode: false,
}

module.exports = nextConfig
