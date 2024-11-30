import SwiftUI

struct ActiveReservationsView: View {
    @EnvironmentObject var reservationManager: ReservationManager
    @State private var showingExtendView = false
    @State private var selectedReservation: ParkingReservation?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(reservationManager.reservations.filter { $0.isActive }) { reservation in
                    VStack(alignment: .leading) {
                        Text(reservation.parkingSpot.name)
                            .font(.headline)
                        Text("Start: \(formatDate(reservation.startTime))")
                        Text("End: \(formatDate(reservation.endTime))")
                        Text("Total: RM \(String(format: "%.2f", reservation.totalPrice))")
                        
                        Button("Extend") {
                            selectedReservation = reservation
                            showingExtendView = true
                        }
                        .padding(.top, 5)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Active Reservations")
        }
        .sheet(isPresented: $showingExtendView) {
            if let reservation = selectedReservation {
                ExtendParkingView(reservation: reservation)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
}

