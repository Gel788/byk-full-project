// Core data models
export interface Restaurant {
  id: string
  name: string
  description: string
  address: string
  city: string
  imageURL: string
  rating: number
  cuisine: string
  deliveryTime: number
  brand: RestaurantBrand
  menu: Dish[]
  features: Feature[]
  workingHours: WorkingHours
  location: Location
  tables: Table[]
  gallery: GalleryImage[]
  contacts: ContactInfo
  averageCheck: number
  atmosphere: string
  isActive: boolean
  createdAt: string
}

export interface Dish {
  id: string
  name: string
  description: string
  price: number
  image: string
  category: string
  restaurantBrand: RestaurantBrand
  isAvailable: boolean
  preparationTime: number
  calories: number
  allergens: string[]
  tags: DishTag[]
  spicyLevel: SpicyLevel
}

export interface Order {
  id: string
  customer: Customer
  restaurant: {
    name: string
    address: string
  }
  items: OrderItem[]
  total: number
  status: OrderStatus
  paymentMethod: PaymentMethod
  deliveryType: DeliveryType
  deliveryAddress?: string
  createdAt: string
  estimatedDelivery?: string
  actualDelivery?: string
  notes?: string
}

export interface OrderItem {
  name: string
  quantity: number
  price: number
}

export interface Reservation {
  id: string
  customer: Customer
  restaurant: {
    name: string
    address: string
  }
  date: string
  guestCount: number
  status: ReservationStatus
  tableNumber?: string
  specialRequests?: string
  createdAt: string
}

export interface User {
  id: string
  name: string
  email: string
  phone: string
  registrationDate: string
  lastVisit: string
  totalOrders: number
  totalSpent: number
  averageOrder: number
  rating: number
  isActive: boolean
  avatar?: string
}

export interface NewsItem {
  id: string
  title: string
  description: string
  image: string
  date: string
  brand: RestaurantBrand
  type: NewsType
  likes: number
  isLiked: boolean
  comments: number
  isRead: boolean
}

// Enums
export enum RestaurantBrand {
  THE_BYK = 'THE_BYK',
  THE_PIVO = 'THE_PIVO',
  MOSCA = 'MOSCA',
  THE_GEORGIA = 'THE_GEORGIA'
}

export enum Feature {
  DELIVERY = 'DELIVERY',
  PICKUP = 'PICKUP',
  RESERVATION = 'RESERVATION',
  PARKING = 'PARKING',
  WIFI = 'WIFI',
  LIVE_MUSIC = 'LIVE_MUSIC',
  OUTDOOR_SEATING = 'OUTDOOR_SEATING',
  PRIVATE_ROOMS = 'PRIVATE_ROOMS'
}

export enum Weekday {
  MONDAY = 'MONDAY',
  TUESDAY = 'TUESDAY',
  WEDNESDAY = 'WEDNESDAY',
  THURSDAY = 'THURSDAY',
  FRIDAY = 'FRIDAY',
  SATURDAY = 'SATURDAY',
  SUNDAY = 'SUNDAY'
}

export enum TableLocation {
  INDOOR = 'INDOOR',
  OUTDOOR = 'OUTDOOR',
  PRIVATE = 'PRIVATE',
  BAR = 'BAR'
}

export enum OrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  PREPARING = 'PREPARING',
  READY = 'READY',
  IN_DELIVERY = 'IN_DELIVERY',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED'
}

export enum PaymentMethod {
  CARD = 'CARD',
  CASH = 'CASH',
  ONLINE = 'ONLINE'
}

export enum DeliveryType {
  DELIVERY = 'DELIVERY',
  PICKUP = 'PICKUP'
}

export enum ReservationStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED'
}

export enum DishTag {
  VEGETARIAN = 'VEGETARIAN',
  VEGAN = 'VEGAN',
  GLUTEN_FREE = 'GLUTEN_FREE',
  SPICY = 'SPICY',
  BESTSELLER = 'BESTSELLER',
  CHEF_SPECIAL = 'CHEF_SPECIAL',
  SEASONAL = 'SEASONAL'
}

export enum SpicyLevel {
  NONE = 'NONE',
  MILD = 'MILD',
  MEDIUM = 'MEDIUM',
  HOT = 'HOT',
  EXTRA_HOT = 'EXTRA_HOT'
}

export enum NewsType {
  NEWS = 'NEWS',
  EVENT = 'EVENT',
  PROMOTION = 'PROMOTION'
}

export enum NotificationType {
  MENU_UPDATE = 'MENU_UPDATE',
  SYSTEM_ALERT = 'SYSTEM_ALERT',
  PROMOTION = 'PROMOTION',
  ORDER_ALERT = 'ORDER_ALERT',
  RESERVATION_ALERT = 'RESERVATION_ALERT',
  REVIEW_ALERT = 'REVIEW_ALERT'
}

export enum NotificationPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT'
}

// Helper interfaces
export interface Location {
  latitude: number
  longitude: number
}

export interface WorkingHours {
  monday: DaySchedule
  tuesday: DaySchedule
  wednesday: DaySchedule
  thursday: DaySchedule
  friday: DaySchedule
  saturday: DaySchedule
  sunday: DaySchedule
}

export interface DaySchedule {
  open: string
  close: string
  isOpen: boolean
}

export interface Table {
  number: string
  capacity: number
  location: TableLocation
  isAvailable: boolean
}

export interface GalleryImage {
  id: string
  url: string
  caption?: string
}

export interface ContactInfo {
  phone: string
  email: string
  website?: string
}

export interface Customer {
  name: string
  phone: string
  email: string
}

// API and utility types
export interface ApiResponse<T> {
  data: T
  success: boolean
  message?: string
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
  totalPages: number
}

export interface FilterOptions {
  search?: string
  brand?: RestaurantBrand
  category?: string
  status?: string
  dateFrom?: string
  dateTo?: string
  page?: number
  limit?: number
}

export interface DashboardStats {
  totalRestaurants: number
  activeOrders: number
  dailyReservations: number
  monthlyRevenue: number
}

export interface ActivityItem {
  id: string
  type: 'order' | 'reservation' | 'review' | 'system'
  title: string
  description: string
  timestamp: string
  priority: 'low' | 'medium' | 'high'
} 