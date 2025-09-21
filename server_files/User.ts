import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUser extends Document {
  _id: string;
  phoneNumber: string;
  password: string;
  fullName: string;
  email?: string;
  avatar?: string;
  isVerified: boolean;
  followersCount: number;
  followingCount: number;
  postsCount: number;
  refreshTokens: string[];
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>({
  phoneNumber: { 
    type: String, 
    required: true,
    unique: true,
    trim: true
  },
  password: { 
    type: String, 
    required: true,
    minlength: 6
  },
  fullName: { 
    type: String, 
    required: true,
    trim: true
  },
  email: { 
    type: String, 
    required: false,
    trim: true,
    lowercase: true
  },
  avatar: { 
    type: String, 
    required: false,
    default: ''
  },
  isVerified: { 
    type: Boolean, 
    required: true,
    default: false
  },
  followersCount: { 
    type: Number, 
    required: true,
    default: 0
  },
  followingCount: { 
    type: Number, 
    required: true,
    default: 0
  },
  postsCount: { 
    type: Number, 
    required: true,
    default: 0
  },
  refreshTokens: [{
    type: String
  }]
}, {
  timestamps: true
});

// Хеширование пароля перед сохранением
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error: any) {
    next(error);
  }
});

// Метод для сравнения паролей
UserSchema.methods.comparePassword = async function(candidatePassword: string): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.password);
};

export default mongoose.model<IUser>('User', UserSchema);
