import Foundation
import CoreLocation

enum ParkingType: String, CaseIterable {
    case all, normal, ev
}

struct ParkingSpot: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let pricePerHour: Double
    let distance: Double
    let type: ParkingType
}

struct ParkingReservation: Identifiable {
    let id: UUID
    let parkingSpot: ParkingSpot
    let hours: Int
    let plateNumber: String
    let name: String
    let totalPrice: Double
}

let sampleParkingSpots = [
    ParkingSpot(name: "Downtown Parking", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), pricePerHour: 5.0, distance: 0.5, type: .normal),
    ParkingSpot(name: "City Center Garage", coordinate: CLLocationCoordinate2D(latitude: 37.7850, longitude: -122.4100), pricePerHour: 7.5, distance: 1.2, type: .ev),
    ParkingSpot(name: "Harbor View Parking", coordinate: CLLocationCoordinate2D(latitude: 37.8000, longitude: -122.4300), pricePerHour: 6.0, distance: 2.0, type: .normal),
    ParkingSpot(name: "Tech Park EV Station", coordinate: CLLocationCoordinate2D(latitude: 37.7900, longitude: -122.4000), pricePerHour: 8.0, distance: 1.5, type: .ev),
    ParkingSpot(name: "Central Square Lot", coordinate: CLLocationCoordinate2D(latitude: 37.7700, longitude: -122.4250), pricePerHour: 4.5, distance: 0.8, type: .normal)
]

