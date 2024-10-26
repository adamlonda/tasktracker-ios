import ComposableArchitecture
import Foundation
import Models
import Reducers

extension TodoListTabReducerTests {

    @MainActor func test_whenReducerIsCreated_thenTodosAreDisplayedCorrectly() async {
        let calendar = Calendar.current
        let now = Date.now

        let completedNow = ToDo.mock(completedAt: now)
        let completedSecondAgo = ToDo.mock(completedAt: .secondAgo(from: now))
        let completedTwoSecondsAgo = ToDo.mock(completedAt: .twoSecondsAgo(from: now), dueDate: now)
        let overdue = ToDo.twoDaysOverdue(from: now)
        let dueYesterday = ToDo.dueYesterday(from: now)
        let dueTodayNormal = ToDo.mock(dueDate: now)
        let dueTodayHigh = ToDo.mock(priority: .high, dueDate: now)
        let dueTodayLow = ToDo.mock(priority: .low, dueDate: now)
        let dueTomorrow = ToDo.dueTomorrow(from: now)
        let dueThisWeek = ToDo.dueThisWeek(from: now)
        let dueNextWeek = ToDo.dueNextWeek(from: now)
        let trashedTwoSecondsAgo = ToDo.mock(trashedAt: .twoSecondsAgo(from: now))
        let trashedSecondAgo = ToDo.mock(trashedAt: .secondAgo(from: now))
        let trashedNow = ToDo.mock(trashedAt: now)

        @Shared(.todoStorage) var todos = [
            .lowPriority, .normalPriority, .highPriority, completedTwoSecondsAgo, completedSecondAgo, completedNow,
            overdue, dueYesterday, dueTodayNormal, dueTodayHigh, dueTodayLow, dueTomorrow, dueThisWeek, dueNextWeek,
            trashedTwoSecondsAgo, trashedSecondAgo, trashedNow
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
            .today: [overdue, dueYesterday, dueTodayHigh, dueTodayNormal, dueTodayLow],
            .trashBin: [trashedNow, trashedSecondAgo, trashedTwoSecondsAgo]
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
                    uniqueElements: expectedDisplayedTodos
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
            $0.displayedTodos = [first]
        }
    }
}
