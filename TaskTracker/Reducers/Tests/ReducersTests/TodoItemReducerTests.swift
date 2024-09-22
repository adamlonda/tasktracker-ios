import ComposableArchitecture
import Models
@testable import Reducers
import XCTest

final class TodoItemReducerTests: XCTestCase {

    @MainActor func test_whenCompletionRequestedOnCompleted_thenCompletionIsNilled() async {
        let store = TestStore(
            initialState: .mock(title: "Buy coffee", completedAt: .now)
        ) {
            TodoItemReducer()
        }

        await store.send(.completionAction) {
            $0.completedAt = nil
        }
    }

    @MainActor func test_whenCompletionRequestedOnNotCompleted_thenCompletionMarkIsSet() async {
        let now = Date.now
        let store = TestStore(
            initialState: .mock(title: "Buy coffee", completedAt: nil)
        ) {
            TodoItemReducer()
        } withDependencies: {
            $0.date = .constant(now)
        }

        await store.send(.completionAction) {
            $0.completedAt = now
        }
    }

    @MainActor func test_whenCompletionRequestedOnRecurringTask_thenDueDateIsSetCorrectly() async {
        let now = Date.now
        let calendar = Calendar.current
        let expectationMap: [Recurrence: Date?] = [
            .daily: calendar.date(byAdding: .day, value: 1, to: now)?.trim(with: calendar),
            .weekly: calendar.date(byAdding: .day, value: 7, to: now)?.trim(with: calendar),
            .monthly: calendar.date(byAdding: .month, value: 1, to: now)?.trim(with: calendar),
            .annually: calendar.date(byAdding: .year, value: 1, to: now)?.trim(with: calendar)
        ]

        for (recurrence, expectedDueDate) in expectationMap {
            let todoId = ToDo.ID(UUID(0))
            let todo = ToDo.mock(id: todoId, dueDate: now, recurrence: recurrence)
            let store = TestStore(
                initialState: todo
            ) {
                TodoItemReducer()
            } withDependencies: {
                $0.calendar = calendar
                $0.date = .constant(now)
            }
            store.exhaustivity = .off

            await store.send(.completionAction) {
                $0.completedAt = nil
                $0.dueDate = expectedDueDate
            }
        }
    }
}
