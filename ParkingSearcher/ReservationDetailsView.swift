import SwiftUI
import MapKit

struct ReservationDetailsView: View {
    let reservation: ParkingReservation
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Reservation Confirmed")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        DetailRow(title: "Reservation ID", value: reservation.id.uuidString)
                        DetailRow(title: "Parking Spot", value: reservation.parkingSpot.name)
                        DetailRow(title: "Duration", value: "\(reservation.hours) hours")
                        DetailRow(title: "Plate Number", value: reservation.plateNumber)
                        DetailRow(title: "Name", value: reservation.name)
                        DetailRow(title: "Total Price", value: String(format: "$%.2f", reservation.totalPrice))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    
                    Button(action: openInMaps) {
                        Text("Open in Maps")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    
                    Text("Please arrive at the parking spot within 30 minutes of your reservation time.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationBarTitle("Reservation Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func openInMaps() {
        let placemark = MKPlacemark(coordinate: reservation.parkingSpot.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = reservation.parkingSpot.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

