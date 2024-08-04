import ComposableArchitecture
import Models
@testable import Reducers
import XCTest

final class AppReducerTests: XCTestCase {

    // MARK: - Tab Switching

    @MainActor func test_whenReducerIsCreated_thenSelectedTabIsSetCorrectly() {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }
        store.assert {
            $0.selectedTab = .pending
        }
    }

    @MainActor func test_whenSelectedTabChangedActionReceived_thenSelectedTabIsSetCorrectly() async {
        let expectationMap: [Tab: Tab] = [
            .all: .all,
            .completed: .completed
        ]

        for (selectedTab, expectedTab) in expectationMap {
            let store = TestStore(initialState: AppReducer.State()) {
                AppReducer()
            }
            await store.send(.selectedTabChangedAction(selectedTab)) {
                $0.selectedTab = expectedTab
            }
        }
    }

    @MainActor func test_whenSwitchToPendingDelegateReceived_thenTabIsSwitchedToPending() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        await store.send(.selectedTabChangedAction(.completed))
        await store.send(.completedTabAction(.delegate(.switchToPendingTab))) {
            $0.selectedTab = .pending
        }
    }

    // MARK: - Adding Tap Action

    @MainActor func test_whenAddTodoTapActionReceived_thenTodoFormIsCreated() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addTodoTapAction) {
            $0.todoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(UUID(0)), title: ""))
        }
    }

    // MARK: - Adding Confirmation

    @MainActor func test_whenAddTodoIsConfirmed_thenTodoFormIsDismissed() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        await store.send(.addTodoTapAction) {
            $0.todoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(UUID(0)), title: ""))
        }

        await store.send(.todoFormAction(.presented(.delegate(.save)))) {
            $0.todoForm = nil
        }
    }

    @MainActor func test_whenAddTodoIsConfirmed_thenTodoIsAdded() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        let expectedID = ToDo.ID(UUID(0))

        await store.send(.addTodoTapAction) {
            $0.todoForm = TodoFormReducer.State(todo: ToDo(id: expectedID, title: ""))
        }

        let addedTodo = ToDo(id: expectedID, title: "Buy coffee", priority: .high)
        await store.send(\.todoFormAction.binding.todo, addedTodo)

        await store.send(.todoFormAction(.presented(.delegate(.save)))) {
            $0.storedTodos = [addedTodo]
        }
    }
}
