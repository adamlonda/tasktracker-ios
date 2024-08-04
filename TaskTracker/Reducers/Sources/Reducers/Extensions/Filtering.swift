import IdentifiedCollections
import Models

extension Tab {

    func filteredTodos(from allTodos: IdentifiedArrayOf<ToDo>) -> IdentifiedArrayOf<ToDo> {
        switch self {
        case .all:
            return allTodos
        case .pending:
            return allTodos.filter { $0.completedAt == nil }
        case .completed:
            return allTodos.filter { $0.completedAt != nil }
        }
    }
}
