"use client";
import { motion } from "framer-motion";
import Link from "next/link";
import { CheckCircle } from "lucide-react";

export default function ReservationSuccess() {
  return (
    <main className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5 }}
        className="flex flex-col items-center bg-gray-900 rounded-2xl p-10 shadow-xl"
      >
        <CheckCircle className="w-20 h-20 text-green-500 mb-6" />
        <h1 className="text-3xl sm:text-4xl font-bold text-white mb-4 text-center">Бронирование подтверждено!</h1>
        <p className="text-white/70 text-lg mb-8 text-center max-w-md">
          Спасибо за бронирование стола. Мы ждём вас в нашем ресторане! Подробности доступны в вашем профиле.
        </p>
        <Link href="/profile" className="bg-orange-600 hover:bg-orange-700 text-white font-bold py-3 px-8 rounded-lg text-lg transition-colors">
          В профиль
        </Link>
      </motion.div>
    </main>
  );
} 