import ComposableArchitecture
import Reducers
import XCTest

final class TodoItemReducerTests: XCTestCase {

    @MainActor func test_whenToggleOnCompleted_thenCompletedIsFalse() async {
        let store = TestStore(
            initialState: .mock(title: "Buy coffee", isCompleted: true)
        ) {
            TodoItemReducer()
        }

        await store.send(.toggleCompletionAction) {
            $0.isCompleted = false
        }
    }

    @MainActor func test_whenToggleOnNotCompleted_thenCompletedIsTrue() async {
        let store = TestStore(
            initialState: .mock(title: "Buy coffee", isCompleted: false)
        ) {
            TodoItemReducer()
        }

        await store.send(.toggleCompletionAction) {
            $0.isCompleted = true
        }
    }
}
