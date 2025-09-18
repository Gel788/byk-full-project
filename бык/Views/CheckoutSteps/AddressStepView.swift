import SwiftUI
import CoreLocation

struct AddressStepView: View {
    @ObservedObject var orderData: OrderData
    let restaurant: Restaurant
    @ObservedObject var deliveryService: SmartDeliveryService
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onLocationPicker: () -> Void
    
    @State private var isCalculatingDelivery = false
    @State private var addressValidationMessage: String = ""
    @State private var showingAddressSuggestions = false
    
    var body: some View {
        VStack(spacing: 24) {
            if orderData.deliveryMethod == .delivery {
                deliveryAddressSection
            }
            
            contactInfoSection
        }
        .onChange(of: orderData.address) { _, newValue in
            if orderData.deliveryMethod == .delivery && !newValue.isEmpty {
                Task {
                    await validateAndCalculateDelivery()
                }
            }
        }
    }
    
    // MARK: - Delivery Address Section
    
    private var deliveryAddressSection: some View {
        VStack(spacing: 20) {
            // Заголовок секции
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Адрес доставки")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Поле ввода адреса
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Введите адрес доставки", text: $orderData.address)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            orderData.address.isEmpty ? Color.gray.opacity(0.3) : brandColors.accent,
                                            lineWidth: 1
                                        )
                                )
                        )
                    
                    // Кнопка выбора на карте
                    Button(action: onLocationPicker) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 18))
                            .foregroundColor(brandColors.accent)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(brandColors.accent.opacity(0.2))
                            )
                    }
                }
                
                // Сообщение валидации
                if !addressValidationMessage.isEmpty {
                    Text(addressValidationMessage)
                        .font(.system(size: 12))
                        .foregroundColor(orderData.deliveryCalculation?.isAvailable == false ? .red : brandColors.accent)
                        .padding(.horizontal, 4)
                }
            }
            
            // Кнопка определения местоположения
            LocationDetectionButton(
                deliveryService: deliveryService,
                orderData: orderData,
                brandColors: brandColors
            )
            
            // Расчет доставки
            if let calculation = orderData.deliveryCalculation {
                DeliveryCalculationCard(
                    calculation: calculation,
                    brandColors: brandColors
                )
            } else if isCalculatingDelivery {
                DeliveryCalculationLoadingView(brandColors: brandColors)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Contact Info Section
    
    private var contactInfoSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Контактные данные")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Имя
                CustomTextField(
                    title: "Ваше имя",
                    text: $orderData.name,
                    placeholder: "Введите имя",
                    icon: "person",
                    brandColors: brandColors
                )
                
                // Телефон
                CustomTextField(
                    title: "Номер телефона",
                    text: $orderData.phone,
                    placeholder: "+7 (999) 123-45-67",
                    icon: "phone",
                    brandColors: brandColors,
                    keyboardType: .phonePad
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Private Methods
    
    private func validateAndCalculateDelivery() async {
        guard orderData.deliveryMethod == .delivery,
              !orderData.address.isEmpty else { return }
        
        await MainActor.run {
            isCalculatingDelivery = true
            addressValidationMessage = "Проверяем адрес..."
        }
        
        let calculation = await deliveryService.calculateDelivery(
            to: orderData.address,
            coordinate: orderData.coordinate,
            restaurant: restaurant,
            orderAmount: 0 // Будет обновлено позже
        )
        
        await MainActor.run {
            isCalculatingDelivery = false
            orderData.deliveryCalculation = calculation
            
            if calculation.isAvailable {
                addressValidationMessage = "Адрес подтвержден"
            } else {
                addressValidationMessage = calculation.reason ?? "Доставка недоступна"
            }
        }
    }
}

// MARK: - Location Detection Button

struct LocationDetectionButton: View {
    @ObservedObject var deliveryService: SmartDeliveryService
    @ObservedObject var orderData: OrderData
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    @State private var isDetectingLocation = false
    
    var body: some View {
        Button(action: detectCurrentLocation) {
            HStack {
                if isDetectingLocation {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: brandColors.accent))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(brandColors.accent)
                }
                
                Text(isDetectingLocation ? "Определяем местоположение..." : "Определить мое местоположение")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(brandColors.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(brandColors.accent, lineWidth: 1)
            )
        }
        .disabled(isDetectingLocation)
    }
    
    private func detectCurrentLocation() {
        isDetectingLocation = true
        
        Task {
            if let location = await deliveryService.getCurrentLocation() {
                // Обратное геокодирование для получения адреса
                let geocoder = CLGeocoder()
                
                do {
                    let placemarks = try await geocoder.reverseGeocodeLocation(
                        CLLocation(latitude: location.latitude, longitude: location.longitude)
                    )
                    
                    if let placemark = placemarks.first {
                        await MainActor.run {
                            orderData.coordinate = location
                            
                            // Формируем адрес из компонентов
                            var addressComponents: [String] = []
                            
                            if let street = placemark.thoroughfare {
                                addressComponents.append(street)
                            }
                            
                            if let number = placemark.subThoroughfare {
                                addressComponents.append(number)
                            }
                            
                            orderData.address = addressComponents.joined(separator: ", ")
                        }
                    }
                } catch {
                    print("Ошибка обратного геокодирования: \(error)")
                }
            }
            
            await MainActor.run {
                isDetectingLocation = false
            }
        }
    }
}

// MARK: - Delivery Calculation Card

struct DeliveryCalculationCard: View {
    let calculation: DeliveryCalculation
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: calculation.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(calculation.isAvailable ? .green : .red)
                
                Text(calculation.isAvailable ? "Доставка доступна" : "Доставка недоступна")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if calculation.isAvailable {
                VStack(spacing: 12) {
                    DeliveryDetailRow(
                        icon: "car.fill",
                        title: "Стоимость доставки",
                        value: calculation.isFreeDelivery ? "Бесплатно" : "\(Int(calculation.deliveryFee)) ₽",
                        color: calculation.isFreeDelivery ? .green : brandColors.accent
                    )
                    
                    DeliveryDetailRow(
                        icon: "clock.fill",
                        title: "Время доставки",
                        value: "\(calculation.estimatedTime) мин",
                        color: brandColors.accent
                    )
                    
                    DeliveryDetailRow(
                        icon: "location.fill",
                        title: "Расстояние",
                        value: String(format: "%.1f км", calculation.distance),
                        color: brandColors.accent
                    )
                    
                    if let zone = calculation.zone {
                        DeliveryDetailRow(
                            icon: "map.fill",
                            title: "Зона доставки",
                            value: zone.name,
                            color: brandColors.accent
                        )
                    }
                }
            } else if let reason = calculation.reason {
                Text(reason)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(calculation.isAvailable ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            calculation.isAvailable ? Color.green.opacity(0.3) : Color.red.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct DeliveryDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Loading View

struct DeliveryCalculationLoadingView: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: brandColors.accent))
                .scaleEffect(0.8)
            
            Text("Рассчитываем стоимость доставки...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
        )
    }
}

#Preview {
    AddressStepView(
        orderData: OrderData(),
        restaurant: Restaurant.mock,
        deliveryService: SmartDeliveryService(),
        brandColors: Colors.brandColors(for: .theByk)
    ) {
        // Location picker action
    }
    .background(Color.black)
}