import mongoose, { Document, Schema } from 'mongoose';

export interface IReservation extends Document {
  userId: string;
  restaurantId: string;
  date: Date;
  time: string;
  guests: number;
  status: 'pending' | 'confirmed' | 'cancelled';
  specialRequests?: string;
  reservationNumber: string;
  contactName?: string;
  contactPhone?: string;
  tableNumber?: number;
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
  reservationNumber: { type: String, unique: true, required: true },
  contactName: { type: String },
  contactPhone: { type: String },
  tableNumber: { type: Number },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model<IReservation>('Reservation', ReservationSchema);
