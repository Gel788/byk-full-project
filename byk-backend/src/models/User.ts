import mongoose, { Document, Schema } from 'mongoose';

export interface IUser extends Document {
  username?: string;
  email: string;
  password: string;
  fullName: string;
  phone?: string;
  phoneNumber?: string;
  role?: 'admin' | 'user';
  isActive?: boolean;
  avatar?: string;
  isVerified?: boolean;
  followersCount?: number;
  followingCount?: number;
  postsCount?: number;
  refreshTokens?: string[];
  createdAt?: Date;
  updatedAt?: Date;
}

const UserSchema = new Schema({
  username: { type: String, unique: true, sparse: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  fullName: { type: String, required: true },
  phone: { type: String },
  phoneNumber: { type: String },
  role: { type: String, enum: ['admin', 'user'], default: 'user' },
  isActive: { type: Boolean, default: true },
  avatar: { type: String, default: '' },
  isVerified: { type: Boolean, default: false },
  followersCount: { type: Number, default: 0 },
  followingCount: { type: Number, default: 0 },
  postsCount: { type: Number, default: 0 },
  refreshTokens: [{ type: String }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model<IUser>('User', UserSchema);
