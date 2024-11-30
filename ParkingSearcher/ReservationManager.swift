import Foundation
import UserNotifications

class ReservationManager: ObservableObject {
    @Published var reservations: [ParkingReservation] = []
    
    init() {
        loadReservations()
    }
    
    func addReservation(_ reservation: ParkingReservation) {
        reservations.append(reservation)
        saveReservations()
        scheduleNotification(for: reservation)
    }
    
    func updateReservation(_ reservation: ParkingReservation) {
        if let index = reservations.firstIndex(where: { $0.id == reservation.id }) {
            reservations[index] = reservation
            saveReservations()
            cancelNotification(for: reservation)
            scheduleNotification(for: reservation)
        }
    }
    
    private func loadReservations() {
        if let data = UserDefaults.standard.data(forKey: "parkingReservations"),
           let decodedReservations = try? JSONDecoder().decode([ParkingReservation].self, from: data) {
            reservations = decodedReservations
        }
    }
    
    private func saveReservations() {
        if let encodedData = try? JSONEncoder().encode(reservations) {
            UserDefaults.standard.set(encodedData, forKey: "parkingReservations")
        }
    }
    
    private func scheduleNotification(for reservation: ParkingReservation) {
        let content = UNMutableNotificationContent()
        content.title = "Parking Time Expiring Soon"
        content.body = "Your parking at \(reservation.parkingSpot.name) will expire in 30 minutes. Do you want to extend?"
        content.sound = .default
        content.userInfo = ["reservationId": reservation.id.uuidString]
        
        let triggerDate = reservation.endTime.addingTimeInterval(-30 * 60)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: reservation.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotification(for reservation: ParkingReservation) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reservation.id.uuidString])
    }
}

