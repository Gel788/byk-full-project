import mongoose, { Document, Schema } from 'mongoose';

export interface IOrder extends Document {
  userId: string;
  userName?: string;
  restaurantId: string;
  restaurantName?: string;
  orderNumber?: string;
  items: {
    dishId: string;
    dishName?: string;
    quantity: number;
    price: number;
  }[];
  totalAmount: number;
  status: 'pending' | 'confirmed' | 'preparing' | 'ready' | 'delivered' | 'cancelled';
  deliveryMethod: 'delivery' | 'pickup';
  deliveryAddress?: string;
  pickupRestaurantId?: string;
  paymentMethod: 'card' | 'cash' | 'online';
  createdAt: Date;
  updatedAt: Date;
}

const OrderSchema = new Schema({
  userId: { type: String, required: true },
  userName: { type: String },
  restaurantId: { type: String, required: true },
  restaurantName: { type: String },
  orderNumber: { type: String },
  items: [{
    dishId: { type: String, required: true },
    dishName: { type: String },
    quantity: { type: Number, required: true },
    price: { type: Number, required: true }
  }],
  totalAmount: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'], default: 'pending' },
  deliveryMethod: { type: String, enum: ['delivery', 'pickup'], required: true },
  deliveryAddress: { type: String },
  pickupRestaurantId: { type: String },
  paymentMethod: { type: String, enum: ['card', 'cash', 'online'], required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model<IOrder>('Order', OrderSchema);
