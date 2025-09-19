import mongoose, { Document, Schema } from 'mongoose';

export interface ICategory extends Document {
  name: string;
  description?: string;
  brandId: mongoose.Types.ObjectId;
  order: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const CategorySchema = new Schema<ICategory>({
  name: { 
    type: String, 
    required: true,
    trim: true
  },
  description: { 
    type: String, 
    required: false 
  },
  brandId: { 
    type: Schema.Types.ObjectId, 
    ref: 'Brand',
    required: true
  },
  order: { 
    type: Number, 
    required: true,
    default: 0
  },
  isActive: { 
    type: Boolean, 
    required: true,
    default: true
  }
}, {
  timestamps: true
});

export default mongoose.model<ICategory>('Category', CategorySchema);
