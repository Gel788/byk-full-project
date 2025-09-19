import mongoose, { Document, Schema } from 'mongoose';

export interface IBrand extends Document {
  name: string;
  description?: string;
  logo?: string;
  color?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const BrandSchema = new Schema<IBrand>({
  name: { 
    type: String, 
    required: true,
    unique: true,
    trim: true
  },
  description: { 
    type: String, 
    required: false 
  },
  logo: { 
    type: String, 
    required: false,
    default: ''
  },
  color: { 
    type: String, 
    required: false,
    default: '#3B82F6'
  },
  isActive: { 
    type: Boolean, 
    required: true,
    default: true
  }
}, {
  timestamps: true
});

export default mongoose.model<IBrand>('Brand', BrandSchema);
