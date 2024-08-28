import ComposableArchitecture
import Reducers
import XCTest

final class TodoItemReducerTests: XCTestCase {

    @MainActor func test_whenToggleOnCompleted_thenCompletedIsFalse() async {
        let store = TestStore(
            initialState: .init(todo: .mock(title: "Buy coffee", completedAt: .now), dueLabel: nil)
        ) {
            TodoItemReducer()
        }

        await store.send(.toggleCompletionAction) {
            $0.todo.completedAt = nil
        }
    }

    @MainActor func test_whenToggleOnNotCompleted_thenCompletedIsTrue() async {
        let now = Date.now
        let store = TestStore(
            initialState: .init(todo: .mock(title: "Buy coffee", completedAt: nil), dueLabel: nil)
        ) {
            TodoItemReducer()
        }
        store.dependencies.date = .constant(now)

        await store.send(.toggleCompletionAction) {
            $0.todo.completedAt = now
        }
    }
}
