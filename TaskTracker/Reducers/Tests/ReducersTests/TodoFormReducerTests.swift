import ComposableArchitecture
import Models
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

    @MainActor func test_whenSaveButtonIsTapped_thenDelegateIsTriggered() async {
        let store = TestStore(
            initialState: TodoFormReducer.State(todo: .mock(title: ""))
        ) {
            TodoFormReducer()
        }
        store.exhaustivity = .off

        await store.send(.binding(.set(\.todo.title, "Buy a coffee")))
        await store.send(.saveAction)
        await store.receive {
            $0 == .delegate(.save)
        }
    }

    func test_whenPriorityAllCasesIsCalled_thenOrderShouldBeCorrect() {
        XCTAssertEqual(Priority.allCases, [.high, .normal, .low])
    }

    @MainActor func test_whenDueDateIsCleared_thenRecurrenceShouldBeNever() async {
        let store = TestStore(
            initialState: TodoFormReducer.State(todo: .mock(dueDate: .now, recurrence: .daily))
        ) {
            TodoFormReducer()
        }
        store.exhaustivity = .off

        await store.send(.binding(.set(\.todo.dueDate, nil))) {
            $0.todo.recurrence = .never
        }
    }

    @MainActor func test_whenDueDateIsNil_thenRecurrenceIsDisabled() async {
        let store = TestStore(
            initialState: TodoFormReducer.State(todo: .mock(dueDate: .now))
        ) {
            TodoFormReducer()
        }
        store.exhaustivity = .off

        await store.send(.binding(.set(\.todo.dueDate, nil))) {
            $0.isRecurrenceDisabled = true
        }
    }

    @MainActor func test_whenDueDateIsNotNil_thenRecurrenceIsEnabled() async {
        let store = TestStore(
            initialState: TodoFormReducer.State(todo: .mock(dueDate: nil))
        ) {
            TodoFormReducer()
        }
        store.exhaustivity = .off

        await store.send(.binding(.set(\.todo.dueDate, .now))) {
            $0.isRecurrenceDisabled = false
        }
    }
}
