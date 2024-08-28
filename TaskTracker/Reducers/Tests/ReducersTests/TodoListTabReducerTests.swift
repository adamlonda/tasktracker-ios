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
            $0.displayedTodos = [.init(todo: expectedTodo, dueLabel: .today)]
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
        await store.send(
            \.todoFormAction.binding.todo, .mock(title: "Buy coffee", dueDate: now.addingTimeInterval(24 * 60 * 60))
        )

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

        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.deleteAction(IndexSet(integer: 0))) {
            $0.displayedTodos = [.init(todo: secondTodo, dueLabel: nil)]
        }
    }

    // MARK: - Editing

    @MainActor func test_whenTodoIsTapped_thenTodoFormIsCreated() async {
        let todoID = ToDo.ID(UUID(0))
        let existingTodo = ToDo.mock(id: todoID, title: "Buy coffee")

        @Shared(.todoStorage) var todos = [existingTodo]
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

        @Shared(.todoStorage) var todos = [todo]
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

        @Shared(.todoStorage) var todos = [originalTodo]
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
            $0.displayedTodos = [.init(todo: expectedTodo, dueLabel: .today)]
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
        let store = TestStore(initialState: TodoListTabReducer.State(.all)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.todoItemAction(.element(id: id, action: .toggleCompletionAction))) {
            $0.displayedTodos = [.init(todo: expected, dueLabel: nil)]
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
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
        }
        store.exhaustivity = .off
        await store.send(.onAppearAction)

        await store.send(.todoItemAction(.element(id: secondID, action: .toggleCompletionAction))) {
            $0.displayedTodos = [.init(todo: first, dueLabel: nil)]
        }
    }
}

// MARK: - Displaying

extension TodoListTabReducerTests {

    @MainActor func test_whenReducerIsCreated_thenTodosAreDisplayedCorrectly() async {
        let calendar = Calendar.current
        let now = Date.now

        let completedNow = ToDo.mock(title: "Completed now", completedAt: now)
        let completedSecondAgo = ToDo.mock(title: "Completed second ago", completedAt: now.addingTimeInterval(-1))
        let completedTwoSecondsAgo = ToDo.mock(
            title: "Completed two seconds ago", completedAt: now.addingTimeInterval(-2), dueDate: now
        )
        let overdue = ToDo.mock(title: "Overdue", dueDate: now.addingTimeInterval(-2 * 24 * 60 * 60))
        let dueYesterday = ToDo.mock(title: "Due yesterday", dueDate: now.addingTimeInterval(-24 * 60 * 60))
        let dueTodayNormal = ToDo.mock(title: "Due today", dueDate: now)
        let dueTodayHigh = ToDo.mock(title: "Due today high", priority: .high, dueDate: now)
        let dueTodayLow = ToDo.mock(title: "Due today low", priority: .low, dueDate: now)
        let dueTomorrow = ToDo.mock(title: "Due tomorrow", dueDate: now.addingTimeInterval(24 * 60 * 60))
        let dueThisWeek = ToDo.mock(title: "Due this week", dueDate: now.addingTimeInterval(2 * 24 * 60 * 60))
        let dueNextWeek = ToDo.mock(title: "Due next week", dueDate: now.addingTimeInterval(7 * 24 * 60 * 60))

        @Shared(.todoStorage) var todos = [
            .lowPriority, .normalPriority, .highPriority, completedTwoSecondsAgo, completedSecondAgo, completedNow,
            overdue, dueYesterday, dueTodayNormal, dueTodayHigh, dueTodayLow, dueTomorrow, dueThisWeek, dueNextWeek
        ]

        let expectationMap: [Tab: IdentifiedArrayOf<ToDo>] = [
            .all: [
                overdue, dueYesterday, dueTodayHigh, dueTodayNormal, dueTodayLow, dueTomorrow, dueThisWeek, dueNextWeek,
                .highPriority, .normalPriority, .lowPriority, completedNow, completedSecondAgo, completedTwoSecondsAgo
            ],
            .completed: [completedNow, completedSecondAgo, completedTwoSecondsAgo],
            .pending: [
                overdue, dueYesterday, dueTodayHigh, dueTodayNormal, dueTodayLow, dueTomorrow, dueThisWeek, dueNextWeek,
                .highPriority, .normalPriority, .lowPriority
            ],
            .today: [overdue, dueYesterday, dueTodayHigh, dueTodayNormal, dueTodayLow]
        ]

        for (tab, expectedDisplayedTodos) in expectationMap {
            let store = TestStore(initialState: TodoListTabReducer.State(tab)) {
                TodoListTabReducer()
            } withDependencies: {
                $0.calendar = calendar
                $0.date = .constant(now)
            }
            store.exhaustivity = .off
            await store.send(.onAppearAction)

            store.assert {
                $0.displayedTodos = .init(
                    uniqueElements: expectedDisplayedTodos.map {
                        .init(todo: $0, dueLabel: $0.dueLabel(calendar: calendar, now: now))
                    }
                )
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
        let store = TestStore(initialState: TodoListTabReducer.State(.pending)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = .current
            $0.date = .constant(.now)
        }

        await MainActor.run {
            todos[id: secondID] = .mock(id: secondID, title: "Second todo", completedAt: .now)
        }
        await store.send(.onAppearAction) {
            $0.displayedTodos = [.init(todo: first, dueLabel: nil)]
        }
    }

    @MainActor func test_whenDueDatesAreGiven_thenDueLabelsAreSetCorrectly() async {
        let calendar = Calendar.current
        let now = Date.now
        let expectationMap: [ToDo: DueLabel?] = [
            .mock(title: ""): nil,
            .mock(title: "", dueDate: now.addingTimeInterval(-2 * 24 * 60 * 60)): .overdue,
            .mock(title: "", dueDate: now.addingTimeInterval(-24 * 60 * 60)): .yesterday,
            .mock(title: "", dueDate: now): .today,
            .mock(title: "", dueDate: now.addingTimeInterval(24 * 60 * 60)): .tomorrow,
            .mock(title: "", dueDate: now.addingTimeInterval(2 * 24 * 60 * 60)): .thisWeek,
            .mock(title: "", dueDate: now.addingTimeInterval(7 * 24 * 60 * 60)): .nextWeekAndBeyond
        ]

        @Shared(.todoStorage) var todos = .init(uniqueElements: expectationMap.keys)
        let store = TestStore(initialState: TodoListTabReducer.State(.all)) {
            TodoListTabReducer()
        } withDependencies: {
            $0.calendar = calendar
            $0.date = .constant(now)
        }
        store.exhaustivity = .off

        for (todo, expectedDueLabel) in expectationMap {
            await store.send(.onAppearAction) {
                $0.displayedTodos[id: todo.id] = .init(todo: todo, dueLabel: expectedDueLabel)
            }
        }
    }
}
