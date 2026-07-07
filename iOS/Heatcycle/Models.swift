import Foundation

struct CycleEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var startDate: Date
    var endDate: Date?
    var notes: String
    var createdAt: Date = Date()
}
