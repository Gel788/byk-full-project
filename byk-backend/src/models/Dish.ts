import mongoose, { Document, Schema } from 'mongoose';

export interface IDish extends Document {
  name: string;
  description: string;
  price: number;
  category: string;
  restaurantId: string;
  imageURL: string;
  preparationTime: number;
  calories: number;
  allergens: string[];
  isAvailable: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const DishSchema = new Schema({
  name: { type: String, required: true },
  description: { type: String, required: true },
  price: { type: Number, required: true },
  category: { type: String, required: true },
  restaurantId: { type: Schema.Types.ObjectId, ref: 'Restaurant', required: true },
  imageURL: { type: String, required: false, default: '' },
  preparationTime: { type: Number, default: 15 },
  calories: { type: Number, default: 0 },
  allergens: [{ type: String }],
  isAvailable: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model<IDish>('Dish', DishSchema);
