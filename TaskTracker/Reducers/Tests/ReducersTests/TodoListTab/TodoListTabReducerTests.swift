import ComposableArchitecture
import Models
@testable import Reducers
import XCTest

final class TodoListTabReducerTests: XCTestCase {

    // MARK: - Adding Tap Action

    @MainActor func test_whenAddTodoTapActionReceived_thenTodoFormIsCreated() async {
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date = .constant(.now)
        }

        await store.send(.addTodoTapAction) {
            $0.todoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(UUID(0)), title: ""))
        }
    }

    // MARK: - Adding Confirmation

    @MainActor func test_whenAddTodoIsConfirmed_thenTodoFormIsDismissed() async {
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
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
        let calendar = Calendar.current
        let today = Date.now
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = calendar
            $0.date = .constant(today)
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        let expectedID = ToDo.ID(UUID(0))
        let expectedTitle = "Buy coffee"
        let expectedPriority = Priority.high

        await store.send(.addTodoTapAction) {
            $0.todoForm = TodoFormReducer.State(todo: ToDo(id: expectedID, title: ""))
        }

        let addedTodo = ToDo(id: expectedID, title: expectedTitle, priority: expectedPriority, dueDate: today)
        await store.send(\.todoFormAction.binding.todo, addedTodo)

        let todayTrimmed = today.trim(with: calendar)
        let expectedTodo = ToDo(
            id: expectedID, title: expectedTitle, priority: expectedPriority, dueDate: todayTrimmed
        )
        await store.send(.todoFormAction(.presented(.delegate(.save)))) {
            $0.displayedTodos = [expectedTodo]
        }
    }

    // MARK: - Delegates

    @MainActor func test_whenAddTodoIsConfirmedOnCompletedTab_thenSwitchToPendingDelegateIsExpected() async {
        let store = TestStore(initialState: TodoListTabReducer.State(.completed)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
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

    @MainActor func test_whenAddTodoIsConfirmedOnBinTab_thenSwitchToPendingDelegateIsExpected() async {
        let store = TestStore(initialState: TodoListTabReducer.State(.trashBin)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
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

    @MainActor func test_whenNonTodayTodoIsAddedOnTodayTab_thenSwithToPendingDelegateIsExpected() async {
        let now = Date.now
        let store = TestStore(initialState: TodoListTabReducer.State(.today)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(now)
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        await store.send(.addTodoTapAction)
        await store.send(\.todoFormAction.binding.todo, .dueTomorrow(from: now, title: "Buy coffee"))

        await store.send(.todoFormAction(.presented(.delegate(.save))))
        await store.receive {
            $0 == .delegate(.switchToPendingTab)
        }
    }

    // MARK: - Moving to Trash

    @MainActor func test_whenMoveToTrashIsRequested_thenTodoIsMarkedAsTrashed() async {
        let now = Date.now
        let id = ToDo.ID(UUID(0))
        let firstTodo = ToDo.mock(id: id, title: "First todo")
        let secondTodo = ToDo.mock(title: "Second todo")

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [
            firstTodo,
            secondTodo
        ]

        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.moveToTrashAction(id)) {
            $0.$storedTodos.withLock { storedTodos in
                storedTodos[id: id]?.trashedAt = now
            }
        }
    }

    // MARK: - Moving from Trash

    @MainActor func test_whenMoveFromTrashIsRequested_thenTodoTrashedTimestampIsCleared() async {
        let now = Date.now
        let id = ToDo.ID(UUID(0))
        let firstTodo = ToDo.mock(id: id, title: "First todo", trashedAt: now)
        let secondTodo = ToDo.mock(title: "Second todo", trashedAt: now)

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [
            firstTodo,
            secondTodo
        ]

        let store = TestStore(initialState: TodoListTabReducer.State(.trashBin)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.moveFromTrashAction(id)) {
            $0.$storedTodos.withLock { storedTodos in
                storedTodos[id: id]?.trashedAt = nil
            }
        }
    }

    // MARK: - Deleting Permanently

    @MainActor func test_whenDeleteActionIsRequested_thenWarningAlertShouldBePresented() async {
        let now = Date.now
        let id = ToDo.ID(UUID(0))
        let firstTodo = ToDo.mock(id: id, title: "First todo", trashedAt: now)

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [
            firstTodo
        ]

        let store = TestStore(initialState: TodoListTabReducer.State(.trashBin)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.deleteAction(id)) {
            $0.alert = .deletePermanently(id)
        }
    }

    @MainActor func test_whenDeletionIsConfirmed_thenTodoIsRemoved() async {
        let now = Date.now
        let id = ToDo.ID(UUID(0))
        let firstTodo = ToDo.mock(id: id, title: "First todo", trashedAt: now)
        let secondTodo = ToDo.mock(title: "Second todo", trashedAt: now)

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [
            firstTodo,
            secondTodo
        ]

        let store = TestStore(initialState: TodoListTabReducer.State(.trashBin)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.deleteAction(id))
        await store.send(.alertAction(.presented(.confirmPermanentDeletion(id)))) {
            $0.$storedTodos.withLock { storedTodos in
                storedTodos = [secondTodo]
            }
        }
    }

    // MARK: - Completion

    @MainActor func test_whenCompletionIsChanged_thenChangeIsPersisted() async {
        let id = ToDo.ID(UUID(0))
        let title = "Buy coffee"
        let now = Date.now

        let given = ToDo.mock(id: id, title: title)
        let expected = ToDo.mock(id: id, title: title, completedAt: now)

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [given]
        let store = TestStore(initialState: TodoListTabReducer.State(.all)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.todoItemAction(.element(id: id, action: .completionAction))) {
            $0.displayedTodos = [expected]
            $0.$storedTodos.withLock { storedTodos in
                storedTodos = [expected]
            }
        }
    }

    @MainActor func test_whenCompletionIsChanged_thenTodosAreDisplayedCorrectly() async {
        let secondID = ToDo.ID(UUID(0))

        let first = ToDo.mock(title: "First todo")
        let second = ToDo.mock(id: secondID, title: "Second todo")

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [
            first, second
        ]
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.todoItemAction(.element(id: secondID, action: .completionAction))) {
            $0.displayedTodos = [first]
        }
    }
}

// MARK: - Editing

extension TodoListTabReducerTests {

    @MainActor func test_whenTodoIsTapped_thenTodoFormIsCreated() async {
        let todoID = ToDo.ID(UUID(0))
        let existingTodo = ToDo.mock(id: todoID, title: "Buy coffee")

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [existingTodo]
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.todoItemAction(.element(id: todoID, action: .tapAction))) {
            $0.todoForm = TodoFormReducer.State(todo: existingTodo)
        }
    }

    @MainActor func test_whenChangedTodoIsSaved_thenTodoFormIsDismissed() async {
        let todoID = ToDo.ID(UUID(0))
        let todo = ToDo(id: todoID, title: "Byu coffee")

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [todo]
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.todoItemAction(.element(id: todoID, action: .tapAction))) {
            $0.todoForm = TodoFormReducer.State(todo: todo)
        }

        await store.send(.todoFormAction(.presented(.delegate(.save)))) {
            $0.todoForm = nil
        }
    }

    @MainActor func test_whenChangedTodoIsSaved_thenChangeIsPersisted() async {
        let calendar = Calendar.current
        let today = Date.now
        let todoID = ToDo.ID(UUID(0))
        let originalTodo = ToDo(id: todoID, title: "Byu coffee")

        @Shared(.todoStorage) var todos: IdentifiedArrayOf<ToDo> = [originalTodo]
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = calendar
            $0.date = .constant(today)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.todoItemAction(.element(id: todoID, action: .tapAction))) {
            $0.todoForm = TodoFormReducer.State(todo: originalTodo)
        }

        let expectedTitle = "Buy coffee"
        let expectedNote = "Black presso, if possible 🙏"
        let expectedPriority = Priority.high
        let editedTodo = ToDo(
            id: todoID, title: expectedTitle, note: expectedNote, priority: expectedPriority, dueDate: today
        )
        await store.send(\.todoFormAction.binding.todo, editedTodo)

        let trimmedToday = today.trim(with: calendar)
        let expectedTodo = ToDo(
            id: todoID, title: expectedTitle, note: expectedNote, priority: expectedPriority, dueDate: trimmedToday
        )
        await store.send(.todoFormAction(.presented(.delegate(.save)))) {
            $0.displayedTodos = [expectedTodo]
        }
    }
}
