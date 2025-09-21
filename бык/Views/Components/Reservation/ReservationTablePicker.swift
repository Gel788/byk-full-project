import SwiftUI

struct ReservationTablePicker: View {
    @Binding var selectedTable: Table?
    let availableTables: [Table]
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Выбор стола")
                .font(.headline)
                .foregroundColor(.white)
            
            if availableTables.isEmpty {
                Text("Нет доступных столов")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(availableTables) { table in
                        Button(action: {
                            selectedTable = table
                        }) {
                            VStack {
                                Text("Стол \(table.number)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedTable?.id == table.id ? .black : .white)
                                
                                Text("\(table.capacity) мест")
                                    .font(.caption)
                                    .foregroundColor(selectedTable?.id == table.id ? .black.opacity(0.7) : .gray)
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTable?.id == table.id ? brandColors.accent : Color.clear)
                                    .stroke(brandColors.primary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}
