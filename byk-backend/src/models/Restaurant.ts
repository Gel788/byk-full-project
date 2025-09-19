import mongoose, { Document, Schema } from 'mongoose';

export interface IRestaurant extends Document {
  name: string;
  brandId: mongoose.Types.ObjectId;
  cityId: mongoose.Types.ObjectId;
  address: string;
  phone: string;
  email: string;
  description: string;
  workingHours: string;
  rating: number;
  photos: string[];
  videos: string[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const RestaurantSchema = new Schema({
  name: { type: String, required: true },
  brandId: { 
    type: Schema.Types.ObjectId, 
    ref: 'Brand',
    required: true
  },
  cityId: { 
    type: Schema.Types.ObjectId, 
    ref: 'City',
    required: true
  },
  address: { type: String, required: false, default: '' },
  phone: { type: String, required: false, default: '' },
  email: { type: String, required: false, default: '' },
  description: { type: String, required: false, default: '' },
  workingHours: { type: String, required: false, default: '' },
  rating: { type: Number, default: 0 },
  photos: [{ type: String }],
  videos: [{ type: String }],
  isActive: { type: Boolean, default: true }
}, {
  timestamps: true
});

export default mongoose.model<IRestaurant>('Restaurant', RestaurantSchema);
