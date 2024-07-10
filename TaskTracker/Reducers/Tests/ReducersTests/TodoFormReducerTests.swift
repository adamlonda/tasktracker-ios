import ComposableArchitecture
import ModelsMocks
import Reducers
import XCTest

final class TodoFormReducerTests: XCTestCase {

    @MainActor func test_whenReducerIsCreated_thenTitleIsFocused() {
        let store = TestStore(
            initialState: TodoFormReducer.State(todo: .new)
        ) {
            TodoFormReducer()
        }

        store.assert {
            $0.focus = .title
        }
    }

    @MainActor func test_whenTitleIsEmpty_thenSaveIsDisabled() async {
        let store = TestStore(
            initialState: TodoFormReducer.State(todo: .mock(title: "Buy a coffee"))
        ) {
            TodoFormReducer()
        }
        store.exhaustivity = .off

        await store.send(.binding(.set(\.todo.title, ""))) {
            $0.isSaveDisabled = true
        }
    }

    @MainActor func test_whenTitleIsNotEmpty_thenSaveIsEnabled() async {
        let store = TestStore(
            initialState: TodoFormReducer.State(todo: .mock(title: ""))
        ) {
            TodoFormReducer()
        }
        store.exhaustivity = .off

        await store.send(.binding(.set(\.todo.title, "Buy a coffee"))) {
            $0.isSaveDisabled = false
        }
    }
}
