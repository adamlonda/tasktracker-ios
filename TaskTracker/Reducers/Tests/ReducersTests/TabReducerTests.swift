import ComposableArchitecture
import Models
import Reducers
import XCTest

final class TabReducerTests: XCTestCase {

    // MARK: - Adding Tap Action

    @MainActor func test_whenAddTodoTapActionReceived_thenTodoFormIsCreated() async {
        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addTodoTapAction) {
            $0.todoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(UUID(0)), title: ""))
        }
    }

    // MARK: - Adding Confirmation

    @MainActor func test_whenAddTodoIsConfirmed_thenTodoFormIsDismissed() async {
        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
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
        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
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
            $0.displayedTodos = [addedTodo]
        }
    }

    @MainActor func test_whenAddTodoIsConfirmedOnCompletedTab_thenSwitchToPendingDelegateIsExpected() async {
        let store = TestStore(initialState: TabReducer.State(.completed)) {
            TabReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        await store.send(.addTodoTapAction)
        await store.send(\.todoFormAction.binding.todo, .mock(title: "Buy coffee"))

        await store.send(.todoFormAction(.presented(.delegate(.save))))
        await store.receive {
            $0 == .delegate(.switchToPendingTab)
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

        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
        }
        store.exhaustivity = .off

        await store.send(.deleteAction(IndexSet(integer: 0))) {
            $0.displayedTodos = [secondTodo]
        }
    }

    // MARK: - Editing

    @MainActor func test_whenTodoIsTapped_thenTodoFormIsCreated() async {
        let todoID = ToDo.ID(UUID(0))
        let existingTodo = ToDo.mock(id: todoID, title: "Buy coffee")

        @Shared(.todoStorage) var todos = [existingTodo]
        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
        }

        await store.send(.todoItemAction(.element(id: todoID, action: .tapAction))) {
            $0.todoForm = TodoFormReducer.State(todo: existingTodo)
        }
    }

    @MainActor func test_whenChangedTodoIsSaved_thenTodoFormIsDismissed() async {
        let todoID = ToDo.ID(UUID(0))
        let todo = ToDo(id: todoID, title: "Byu coffee")

        @Shared(.todoStorage) var todos = [todo]
        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
        }
        store.exhaustivity = .off

        await store.send(.todoItemAction(.element(id: todoID, action: .tapAction))) {
            $0.todoForm = TodoFormReducer.State(todo: todo)
        }

        await store.send(.todoFormAction(.presented(.delegate(.save)))) {
            $0.todoForm = nil
        }
    }

    @MainActor func test_whenChangedTodoIsSaved_thenChangeIsPersisted() async {
        let todoID = ToDo.ID(UUID(0))
        let originalTodo = ToDo(id: todoID, title: "Byu coffee")

        @Shared(.todoStorage) var todos = [originalTodo]
        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
        }
        store.exhaustivity = .off

        await store.send(.todoItemAction(.element(id: todoID, action: .tapAction))) {
            $0.todoForm = TodoFormReducer.State(todo: originalTodo)
        }

        let editedTodo = ToDo(id: todoID, title: "Buy coffee", note: "Black presso, if possible 🙏", priority: .high)
        await store.send(\.todoFormAction.binding.todo, editedTodo)

        await store.send(.todoFormAction(.presented(.delegate(.save)))) {
            $0.displayedTodos = [editedTodo]
        }
    }

    // MARK: - Completion

    @MainActor func test_whenCompletionIsToggled_thenChangeIsPersisted() async {
        let id = ToDo.ID(UUID(0))
        let title = "Buy coffee"
        let now = Date.now

        let given = ToDo.mock(id: id, title: title)
        let expected = ToDo.mock(id: id, title: title, completedAt: now)

        @Shared(.todoStorage) var todos = [given]
        let store = TestStore(initialState: TabReducer.State(.all)) {
            TabReducer()
        }
        store.exhaustivity = .off
        store.dependencies.date = .constant(now)

        await store.send(.todoItemAction(.element(id: id, action: .toggleCompletionAction))) {
            $0.displayedTodos = [expected]
            $0.storedTodos = [expected]
        }
    }

    @MainActor func test_whenCompletionIsToggled_thenTodosAreDisplayedCorrectly() async {
        let secondID = ToDo.ID(UUID(0))

        let first = ToDo.mock(title: "First todo")
        let second = ToDo.mock(id: secondID, title: "Second todo")

        @Shared(.todoStorage) var todos = [
            first, second
        ]
        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
        }
        store.exhaustivity = .off
        store.dependencies.date = .constant(.now)

        await store.send(.todoItemAction(.element(id: secondID, action: .toggleCompletionAction))) {
            $0.displayedTodos = [first]
        }
    }

    // MARK: - Displaying

    @MainActor func test_whenReducerIsCreated_thenTodosAreDisplayedCorrectly() {
        let lowTodo = ToDo.mock(title: "Low priority todo", priority: .low)
        let normalTodo = ToDo.mock(title: "Normal priority todo", priority: .normal)
        let highTodo = ToDo.mock(title: "High priority todo", priority: .high)

        let now = Date.now
        let completedNow = ToDo.mock(title: "Completed todo", completedAt: now)
        let completedSecondAgo = ToDo.mock(title: "Second ago", completedAt: now.addingTimeInterval(-1))
        let completedTwoSecondsAgo = ToDo.mock(title: "Two seconds ago", completedAt: now.addingTimeInterval(-2))

        @Shared(.todoStorage) var todos = [
            lowTodo, normalTodo, highTodo, completedTwoSecondsAgo, completedSecondAgo, completedNow
        ]

        let expectationMap: [Tab: IdentifiedArrayOf<ToDo>] = [
            .all: [highTodo, normalTodo, lowTodo, completedNow, completedSecondAgo, completedTwoSecondsAgo],
            .completed: [completedNow, completedSecondAgo, completedTwoSecondsAgo],
            .pending: [highTodo, normalTodo, lowTodo]
        ]

        for (tab, expectedDisplayedTodos) in expectationMap {
            let store = TestStore(initialState: TabReducer.State(tab)) {
                TabReducer()
            }
            store.assert {
                $0.displayedTodos = expectedDisplayedTodos
            }
        }
    }

    @MainActor func test_whenOnAppearIsCalled_thenDisplayedTodosAreUpdated() async {
        let secondID = ToDo.ID(UUID(0))

        let first = ToDo.mock(title: "First todo")
        let second = ToDo.mock(id: secondID, title: "Second todo")

        @Shared(.todoStorage) var todos = [
            first,
            second
        ]
        let store = TestStore(initialState: TabReducer.State(.pending)) {
            TabReducer()
        }

        await MainActor.run {
            todos[id: secondID] = .mock(id: secondID, title: "Second todo", completedAt: .now)
        }
        await store.send(.onAppearAction) {
            $0.displayedTodos = [first]
        }
    }
}
