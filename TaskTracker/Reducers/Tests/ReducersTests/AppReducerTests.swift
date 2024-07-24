import ComposableArchitecture
import Models
@testable import Reducers
import XCTest

final class AppReducerTests: XCTestCase {

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

        await store.send(.saveTodoFormAction) {
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

        let addedTodo = ToDo(id: expectedID, title: "Buy coffee")
        await store.send(\.todoFormAction.binding.todo, addedTodo)

        await store.send(.saveTodoFormAction) {
            $0.todos = [addedTodo]
        }
    }

    // MARK: - Deleting

    @MainActor func test_whenDeleteIsRequested_thenTodoIsRemoved() async {
        let firstTodo = ToDo.mock(title: "First todo")
        let secondTodo = ToDo.mock(title: "Second todo")

        @Shared(.todoStorage) var todos = [
            firstTodo,
            secondTodo
        ]

        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }

        await store.send(.deleteAction(IndexSet(integer: 0))) {
            $0.todos = [secondTodo]
        }
    }

    // MARK: - Editing

    @MainActor func test_whenTodoTitleIsTapped_thenTodoFormIsCreated() async {
        let existingTodo = ToDo.mock(title: "Buy coffee")

        @Shared(.todoStorage) var todos = [existingTodo]
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }

        await store.send(.titleTapAction(existingTodo)) {
            $0.todoForm = TodoFormReducer.State(todo: existingTodo)
        }
    }

    @MainActor func test_whenChangedTodoIsSaved_thenTodoFormIsDismissed() async {
        let todoID = ToDo.ID(UUID(0))
        let todo = ToDo(id: todoID, title: "Byu coffee")

        @Shared(.todoStorage) var todos = [todo]
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }
        store.exhaustivity = .off

        await store.send(.titleTapAction(todo)) {
            $0.todoForm = TodoFormReducer.State(todo: todo)
        }

        await store.send(.saveTodoFormAction) {
            $0.todoForm = nil
        }
    }

    @MainActor func test_whenChangedTodoIsSaved_thenChangeIsPersisted() async {
        let todoID = ToDo.ID(UUID(0))
        let originalTodo = ToDo(id: todoID, title: "Byu coffee")

        @Shared(.todoStorage) var todos = [originalTodo]
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }
        store.exhaustivity = .off

        await store.send(.titleTapAction(originalTodo)) {
            $0.todoForm = TodoFormReducer.State(todo: originalTodo)
        }

        let editedTodo = ToDo(id: todoID, title: "Buy coffee", note: "Black presso, if possible 🙏")
        await store.send(\.todoFormAction.binding.todo, editedTodo)

        await store.send(.saveTodoFormAction) {
            $0.todos = [editedTodo]
        }
    }
}
