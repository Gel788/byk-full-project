import mongoose, { Document, Schema } from 'mongoose';

export interface IReservation extends Document {
  _id: string;
  reservationNumber: string;
  restaurantId: mongoose.Schema.Types.ObjectId;
  restaurantName: string;
  userId: mongoose.Schema.Types.ObjectId;
  date: Date;
  guestCount: number;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  tableNumber: number;
  specialRequests?: string;
  contactPhone?: string;
  contactName?: string;
  createdAt: Date;
  updatedAt: Date;
}

const ReservationSchema = new Schema<IReservation>({
  reservationNumber: {
    type: String,
    required: true,
    unique: true,
    default: () => `RES-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`
  },
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Restaurant'
  },
  restaurantName: {
    type: String,
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  date: {
    type: Date,
    required: true
  },
  guestCount: {
    type: Number,
    required: true,
    min: 1,
    max: 20
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'completed', 'cancelled'],
    default: 'pending'
  },
  tableNumber: {
    type: Number,
    required: true
  },
  specialRequests: {
    type: String,
    required: false,
    maxlength: 500
  },
  contactPhone: {
    type: String,
    required: false,
    trim: true
  },
  contactName: {
    type: String,
    required: false,
    trim: true
  }
}, {
  timestamps: true
});

// Индексы для оптимизации запросов
ReservationSchema.index({ restaurantId: 1, date: 1 });
ReservationSchema.index({ userId: 1, date: 1 });
ReservationSchema.index({ status: 1 });
ReservationSchema.index({ reservationNumber: 1 });

export default mongoose.model<IReservation>('Reservation', ReservationSchema);
