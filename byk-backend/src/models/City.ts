import mongoose, { Document, Schema } from 'mongoose';

export interface ICity extends Document {
  name: string;
  country?: string;
  timezone?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const CitySchema = new Schema<ICity>({
  name: { 
    type: String, 
    required: true,
    unique: true,
    trim: true
  },
  country: { 
    type: String, 
    required: false,
    default: 'Russia'
  },
  timezone: { 
    type: String, 
    required: false,
    default: 'Europe/Moscow'
  },
  isActive: { 
    type: Boolean, 
    required: true,
    default: true
  }
}, {
  timestamps: true
});

export default mongoose.model<ICity>('City', CitySchema);
