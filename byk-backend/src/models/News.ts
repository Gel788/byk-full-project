import mongoose, { Document, Schema } from 'mongoose';

export interface INews extends Document {
  title: string;
  content: string;
  author: string;
  imageURL: string;
  videoURL?: string;
  category: string;
  tags: string[];
  isPublished: boolean;
  publishedAt?: Date;
  views: number;
  likes: number;
  createdAt: Date;
  updatedAt: Date;
}

const NewsSchema = new Schema({
  title: { type: String, required: true },
  content: { type: String, required: true },
  author: { type: String, required: true },
  imageURL: { type: String, required: false, default: '' },
  videoURL: { type: String, required: false, default: '' },
  category: { type: String, required: true },
  tags: [{ type: String }],
  isPublished: { type: Boolean, default: false },
  publishedAt: { type: Date },
  views: { type: Number, default: 0 },
  likes: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model<INews>('News', NewsSchema);
