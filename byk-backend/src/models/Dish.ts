import mongoose, { Document, Schema } from 'mongoose';

export interface IDish extends Document {
  name: string;
  description: string;
  price: number;
  categoryId: mongoose.Types.ObjectId;
  restaurantId: mongoose.Types.ObjectId;
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
  categoryId: { 
    type: Schema.Types.ObjectId, 
    ref: 'Category',
    required: true 
  },
  restaurantId: { 
    type: Schema.Types.ObjectId, 
    ref: 'Restaurant', 
    required: true 
  },
  imageURL: { type: String, required: false, default: '' },
  preparationTime: { type: Number, default: 15 },
  calories: { type: Number, default: 0 },
  allergens: [{ type: String }],
  isAvailable: { type: Boolean, default: true }
}, {
  timestamps: true
});

export default mongoose.model<IDish>('Dish', DishSchema);
