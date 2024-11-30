import SwiftUI

struct ExtendParkingView: View {
    @EnvironmentObject var reservationManager: ReservationManager
    @State private var reservation: ParkingReservation
    @State private var additionalTime: TimeInterval = 3600 // Default to 1 hour
    @Environment(\.presentationMode) var presentationMode
    
    init(reservation: ParkingReservation) {
        _reservation = State(initialValue: reservation)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Reservation")) {
                    Text("Parking Spot: \(reservation.parkingSpot.name)")
                    Text("End Time: \(formatDate(reservation.endTime))")
                }
                
                Section(header: Text("Extend Parking")) {
                    Picker("Additional Time", selection: $additionalTime) {
                        Text("30 minutes").tag(TimeInterval(1800))
                        Text("1 hour").tag(TimeInterval(3600))
                        Text("2 hours").tag(TimeInterval(7200))
                        Text("3 hours").tag(TimeInterval(10800))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text("New End Time: \(formatDate(reservation.endTime.addingTimeInterval(additionalTime)))")
                    Text("Additional Cost: RM \(String(format: "%.2f", additionalCost))")
                }
                
                Button("Confirm Extension") {
                    extendReservation()
                }
            }
            .navigationTitle("Extend Parking")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var additionalCost: Double {
        let additionalHours = additionalTime / 3600
        return reservation.parkingSpot.pricePerHour * additionalHours
    }
    
    private func extendReservation() {
        reservation.endTime = reservation.endTime.addingTimeInterval(additionalTime)
        reservation.totalPrice += additionalCost
        reservationManager.updateReservation(reservation)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
}

