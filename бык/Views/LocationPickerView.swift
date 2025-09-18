import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @Binding var selectedAddress: String
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @ObservedObject var deliveryService: SmartDeliveryService
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173), // Москва
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var pinLocation = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
    @State private var addressText = ""
    @State private var isGeocoding = false
    @State private var addressSuggestions: [String] = []
    @State private var showingSuggestions = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Карта
                Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: pinLocation)]) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 30, height: 30)
                                
                                Image(systemName: "location.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                            
                            // Стрелка
                            Path { path in
                                path.move(to: CGPoint(x: 15, y: 30))
                                path.addLine(to: CGPoint(x: 10, y: 40))
                                path.addLine(to: CGPoint(x: 20, y: 40))
                                path.closeSubpath()
                            }
                            .fill(Color.red)
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                .onTapGesture { location in
                    // Конвертируем точку нажатия в координаты
                    let coordinate = region.center // Упрощенно, для полной реализации нужны дополнительные вычисления
                    updatePinLocation(coordinate)
                }
                
                // Поле поиска адреса
                VStack {
                    VStack(spacing: 0) {
                        HStack {
                            TextField("Поиск адреса", text: $addressText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .onChange(of: addressText) { _, newValue in
                                    searchAddress(newValue)
                                }
                            
                            Button(action: {
                                getCurrentLocation()
                            }) {
                                Image(systemName: "location.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Подсказки адресов
                        if showingSuggestions && !addressSuggestions.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(addressSuggestions.prefix(5), id: \.self) { suggestion in
                                    Button(action: {
                                        selectAddressSuggestion(suggestion)
                                    }) {
                                        HStack {
                                            Image(systemName: "location")
                                                .foregroundColor(.gray)
                                            
                                            Text(suggestion)
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if suggestion != addressSuggestions.prefix(5).last {
                                        Divider()
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // Информация о выбранном адресе
                    VStack(spacing: 16) {
                        if isGeocoding {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                
                                Text("Определяем адрес...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                        } else if !selectedAddress.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.red)
                                    
                                    Text("Выбранный адрес:")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                Text(selectedAddress)
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        
                        // Кнопка подтверждения
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Подтвердить адрес")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    selectedAddress.isEmpty ? Color.gray : Color.blue
                                )
                                .cornerRadius(12)
                        }
                        .disabled(selectedAddress.isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Выбор адреса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let coordinate = selectedCoordinate {
                region.center = coordinate
                pinLocation = coordinate
            } else if !selectedAddress.isEmpty {
                geocodeAddress(selectedAddress)
            }
            
            addressText = selectedAddress
        }
    }
    
    // MARK: - Private Methods
    
    private func updatePinLocation(_ coordinate: CLLocationCoordinate2D) {
        pinLocation = coordinate
        selectedCoordinate = coordinate
        reverseGeocode(coordinate)
    }
    
    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        isGeocoding = true
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                isGeocoding = false
                
                if let placemark = placemarks?.first {
                    var addressComponents: [String] = []
                    
                    if let street = placemark.thoroughfare {
                        addressComponents.append(street)
                    }
                    
                    if let number = placemark.subThoroughfare {
                        addressComponents.append(number)
                    }
                    
                    if let city = placemark.locality {
                        addressComponents.append(city)
                    }
                    
                    selectedAddress = addressComponents.joined(separator: ", ")
                    addressText = selectedAddress
                }
            }
        }
    }
    
    private func geocodeAddress(_ address: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            DispatchQueue.main.async {
                if let coordinate = placemarks?.first?.location?.coordinate {
                    region.center = coordinate
                    pinLocation = coordinate
                    selectedCoordinate = coordinate
                }
            }
        }
    }
    
    private func searchAddress(_ query: String) {
        guard !query.isEmpty else {
            addressSuggestions = []
            showingSuggestions = false
            return
        }
        
        // Простой поиск подсказок (в реальном приложении используйте MKLocalSearch)
        let suggestions = [
            "\(query), Москва",
            "\(query), Санкт-Петербург",
            "\(query), Калуга"
        ].filter { $0.lowercased().contains(query.lowercased()) }
        
        addressSuggestions = suggestions
        showingSuggestions = !suggestions.isEmpty
    }
    
    private func selectAddressSuggestion(_ suggestion: String) {
        addressText = suggestion
        selectedAddress = suggestion
        showingSuggestions = false
        geocodeAddress(suggestion)
    }
    
    private func getCurrentLocation() {
        Task {
            if let location = await deliveryService.getCurrentLocation() {
                await MainActor.run {
                    region.center = location
                    updatePinLocation(location)
                }
            }
        }
    }
}

// MARK: - Map Pin Model

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    LocationPickerView(
        selectedAddress: .constant(""),
        selectedCoordinate: .constant(nil),
        deliveryService: SmartDeliveryService()
    )
}