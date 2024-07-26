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
        await store.send(.selectedTabChangedAction(.all))

        let expectedID = ToDo.ID(UUID(0))

        await store.send(.addTodoTapAction) {
            $0.todoForm = TodoFormReducer.State(todo: ToDo(id: expectedID, title: ""))
        }

        let addedTodo = ToDo(id: expectedID, title: "Buy coffee")
        await store.send(\.todoFormAction.binding.todo, addedTodo)

        await store.send(.saveTodoFormAction) {
            $0.filteredTodos = [addedTodo]
        }
    }

    @MainActor func test_whenAddTodoIsConfirmedOnCompletedTab_thenTabIsSwitchedToPending() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off
        await store.send(.selectedTabChangedAction(.completed))

        await store.send(.addTodoTapAction)
        await store.send(\.todoFormAction.binding.todo, .mock(title: "Buy coffee"))

        await store.send(.saveTodoFormAction) {
            $0.selectedTab = .pending
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
        store.exhaustivity = .off
        await store.send(.selectedTabChangedAction(.all))

        await store.send(.deleteAction(IndexSet(integer: 0))) {
            $0.filteredTodos = [secondTodo]
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
        await store.send(.selectedTabChangedAction(.all))

        await store.send(.titleTapAction(originalTodo)) {
            $0.todoForm = TodoFormReducer.State(todo: originalTodo)
        }

        let editedTodo = ToDo(id: todoID, title: "Buy coffee", note: "Black presso, if possible 🙏")
        await store.send(\.todoFormAction.binding.todo, editedTodo)

        await store.send(.saveTodoFormAction) {
            $0.filteredTodos = [editedTodo]
        }
    }

    @MainActor func test_whenCompletionIsToggled_thenChangeIsPersisted() async {
        let id = ToDo.ID(UUID(0))
        let title = "Buy coffee"

        let given = ToDo.mock(id: id, title: title)
        let expected = ToDo.mock(id: id, title: title, isCompleted: true)

        @Shared(.todoStorage) var todos = [given]
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }
        store.exhaustivity = .off
        await store.send(.selectedTabChangedAction(.all))

        await store.send(.todoItemAction(.element(id: id, action: .toggleCompletionAction))) {
            $0.filteredTodos = [expected]
            $0.storedTodos = [expected]
        }
    }

    // MARK: - Filtering

    @MainActor func test_whenReducerIsCreated_thenSelectedTabIsSetCorrectly() {
        let pendingTodo = ToDo.mock(title: "Pending todo")
        let completedTodo = ToDo.mock(title: "Completed todo", isCompleted: true)

        @Shared(.todoStorage) var todos = [pendingTodo, completedTodo]
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }
        store.assert {
            $0.selectedTab = .pending
            $0.filteredTodos = [pendingTodo]
        }
    }

    @MainActor func test_whenFilterIsSet_thenTodosAreFilteredCorrectly() async {
        let pendingTodo = ToDo.mock(title: "Pending todo")
        let completedTodo = ToDo.mock(title: "Completed todo", isCompleted: true)

        @Shared(.todoStorage) var todos = [pendingTodo, completedTodo]

        let expectationMap: [Tab: IdentifiedArrayOf<ToDo>] = [
            .all: [pendingTodo, completedTodo],
            .completed: [completedTodo]
        ]

        for (tab, expectedFilteredTodos) in expectationMap {
            let store = TestStore(initialState: AppReducer.State()) {
                AppReducer()
            }
            await store.send(.selectedTabChangedAction(tab)) {
                $0.selectedTab = tab
                $0.filteredTodos = expectedFilteredTodos
            }
        }
    }

    @MainActor func test_whenCompletionIsToggled_thenTodosAreFilteredCorrectly() async {
        let secondID = ToDo.ID(UUID(0))

        let first = ToDo.mock(title: "First todo")
        let second = ToDo.mock(id: secondID, title: "Second todo")

        @Shared(.todoStorage) var todos = [
            first, second
        ]
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }
        store.exhaustivity = .off
        await store.send(.selectedTabChangedAction(.pending))

        await store.send(.todoItemAction(.element(id: secondID, action: .toggleCompletionAction))) {
            $0.filteredTodos = [first]
        }
    }
}
