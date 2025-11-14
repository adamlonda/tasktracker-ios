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
            $0.selectedTab = .today
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
        let tabActionMap: [Tab: AppReducer.Action] = [
            .completed: .completedTabAction(.delegate(.switchToPendingTab)),
            .today: .todayTabAction(.delegate(.switchToPendingTab))
        ]

        for (tab, tabAction) in tabActionMap {
            let store = TestStore(initialState: AppReducer.State()) {
                AppReducer()
            } withDependencies: {
                $0.uuid = .incrementing
                $0.date = .constant(.now)
            }
            store.exhaustivity = .off

            await store.send(.selectedTabChangedAction(tab))
            await store.send(tabAction) {
                $0.selectedTab = .pending
            }
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
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.calendar = calendar
            $0.date = .constant(today)
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off

        let expectedID = ToDo.ID(UUID(0))

        await store.send(.addTodoTapAction) {
            $0.todoForm = TodoFormReducer.State(todo: ToDo(id: expectedID, title: ""))
        }

        let expectedTitle = "Buy coffee"
        let expectedPriority = Priority.high
        let addedTodo = ToDo(id: expectedID, title: expectedTitle, priority: expectedPriority, dueDate: today)
        await store.send(\.todoFormAction.binding.todo, addedTodo)

        let expectedDueDate = today.trim(with: calendar)
        let expectedTodo = ToDo(
            id: expectedID, title: expectedTitle, priority: expectedPriority, dueDate: expectedDueDate
        )
        await store.send(.todoFormAction(.presented(.delegate(.save)))) {
            $0.$storedTodos.withLock { storedTodos in
                storedTodos = [expectedTodo]
            }
        }
    }

    @MainActor func test_whenAddTodoIsConfirmed_thenCorrectTabShouldBeSelected() async {
        let now = Date.now
        let dueYesterday = ToDo.dueYesterday(from: now, title: "Due yesterday")
        let dueToday = ToDo.mock(title: "Due today", dueDate: now)
        let dueTomorrow = ToDo.dueTomorrow(from: now, title: "Due tomorrow")

        let expectationMap: [ToDo: Tab] = [
            dueYesterday: .today,
            dueToday: .today,
            dueTomorrow: .pending,
            .normalPriority: .pending
        ]

        for (todo, expectedTab) in expectationMap {
            let store = TestStore(initialState: AppReducer.State()) {
                AppReducer()
            } withDependencies: {
                $0.calendar = .current
                $0.date = .constant(now)
                $0.uuid = .incrementing
            }
            store.exhaustivity = .off

            await store.send(.addTodoTapAction)
            await store.send(\.todoFormAction.binding.todo, todo)
            await store.send(.todoFormAction(.presented(.delegate(.save)))) {
                $0.selectedTab = expectedTab
            }
        }
    }
}
