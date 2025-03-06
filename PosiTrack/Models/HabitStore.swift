import Foundation
import Combine

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
}
