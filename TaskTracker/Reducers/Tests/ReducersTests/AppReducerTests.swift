import ComposableArchitecture
import Models
@testable import Reducers
import XCTest

final class AppReducerTests: XCTestCase {

    @MainActor func test_whenAddTodoTapActionReceived_thenAddTodoFormIsCreated() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addTodoTapAction) {
            $0.addTodoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(UUID(0)), title: ""))
        }
    }

    @MainActor func test_whenAddTodoIsConfirmed_thenAddTodoFormIsDismissed() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        await store.send(.addTodoTapAction) {
            $0.addTodoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(UUID(0)), title: ""))
        }

        await store.send(.confirmAddTodoAction) {
            $0.addTodoForm = nil
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
            $0.addTodoForm = TodoFormReducer.State(todo: ToDo(id: expectedID, title: ""))
        }

        let addedTodo = ToDo(id: expectedID, title: "Buy coffee")
        await store.send(\.addTodoFormAction.binding.todo, addedTodo)

        await store.send(.confirmAddTodoAction) {
            $0.todos = [addedTodo]
        }
    }

    @MainActor func test_whenDeleteIsRequested_thenTodoIsRemoved() async {
        let firstTodo = ToDo.mock(title: "First todo")
        let secondTodo = ToDo.mock(title: "Second todo")

        @Shared(.todos) var todos = [
            firstTodo,
            secondTodo
        ]

        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }

        await store.send(.onDeleteAction(IndexSet(integer: 0))) {
            $0.todos = [secondTodo]
        }
    }
}
