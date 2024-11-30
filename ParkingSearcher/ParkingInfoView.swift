import SwiftUI

struct ParkingInfoView: View {
    let parking: ParkingSpot
    @State private var showingReservation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(parking.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Label("$\(String(format: "%.2f", parking.pricePerHour))/hour", systemImage: "dollarsign.circle")
                Spacer()
                Label(String(format: "%.1f km", parking.distance), systemImage: "location.circle")
            }
            .foregroundColor(.secondary)
            
            Button(action: {
                showingReservation = true
            }) {
                Text("Reserve")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
        .sheet(isPresented: $showingReservation) {
            ReservationView(parking: parking)
        }
    }
}

