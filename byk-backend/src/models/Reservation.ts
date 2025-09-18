import mongoose, { Document, Schema } from 'mongoose';

export interface IReservation extends Document {
  userId: string;
  restaurantId: string;
  date: Date;
  time: string;
  guests: number;
  status: 'pending' | 'confirmed' | 'cancelled';
  specialRequests?: string;
  createdAt: Date;
  updatedAt: Date;
}

const ReservationSchema = new Schema({
  userId: { type: String, required: true },
  restaurantId: { type: String, required: true },
  date: { type: Date, required: true },
  time: { type: String, required: true },
  guests: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'confirmed', 'cancelled'], default: 'pending' },
  specialRequests: { type: String },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model<IReservation>('Reservation', ReservationSchema);
