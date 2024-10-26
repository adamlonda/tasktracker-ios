import ComposableArchitecture
import Foundation
import Models

@Reducer public struct TodoListTabReducer {

    @CasePathable public enum Alert: Sendable, Equatable {
        case confirmPermanentDeletion(ToDo.ID)
    }

    @ObservableState public struct State: Equatable {
        @Shared(.todoStorage) public var storedTodos: IdentifiedArrayOf<ToDo> = []
        public var displayedTodos: IdentifiedArrayOf<TodoItemReducer.State> = []

        @Presents public var todoForm: TodoFormReducer.State?
        @Presents public var alert: AlertState<Alert>?
        public let tab: Tab

        public init(_ tab: Tab) {
            self.tab = tab
        }
    }

    public enum Delegate: Equatable {
        case switchToPendingTab
    }

    public enum Action: Equatable {
        case addTodoTapAction
        case moveToTrashAction(ToDo.ID)
        case moveFromTrashAction(ToDo.ID)
        case deleteAction(ToDo.ID)
        case todoFormAction(PresentationAction<TodoFormReducer.Action>)
        case alertAction(PresentationAction<Alert>)
        case todoItemAction(IdentifiedActionOf<TodoItemReducer>)
        case delegate(Delegate)
        case onAppearAction
    }

    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addTodoTapAction:
                return reduceAddTodoTap(state: &state)
            case .moveToTrashAction(let todoID):
                return reduceMoveToTrash(state: &state, todoID: todoID)
            case .moveFromTrashAction(let todoID):
                return reduceMoveFromTrash(state: &state, todoID: todoID)
            case .deleteAction(let todoID):
                return reduceDelete(state: &state, todoID: todoID)
            case .todoFormAction(let formAction):
                return reduceSaveTodoForm(state: &state, formAction: formAction)
            case .alertAction(let alert):
                return reduceAlert(state: &state, alert: alert)
            case .todoItemAction(let action):
                return reduceTodoItem(state: &state, action: action)
            case .delegate:
                return .none
            case .onAppearAction:
                return reduceOnAppear(state: &state)
            }
        }
        .ifLet(\.$todoForm, action: \.todoFormAction) {
            TodoFormReducer()
        }
        .ifLet(\.$alert, action: \.alertAction)
        .forEach(\.displayedTodos, action: \.todoItemAction) {
            TodoItemReducer()
                .dependency(\.date, date)
        }
    }

    // MARK: - Reduce Methods

    private func reduceAddTodoTap(state: inout State) -> Effect<Action> {
        state.todoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(uuid()), title: ""))
        return .none
    }

    private func reduceMoveToTrash(state: inout State, todoID: ToDo.ID) -> Effect<Action> {
        state.storedTodos[id: todoID]?.trashedAt = date.now
        updateDisplayedTodos(on: &state)
        return .none
    }

    private func reduceMoveFromTrash(state: inout State, todoID: ToDo.ID) -> Effect<Action> {
        state.storedTodos[id: todoID]?.trashedAt = nil
        updateDisplayedTodos(on: &state)
        return .none
    }

    private func reduceDelete(state: inout State, todoID: ToDo.ID) -> Effect<Action> {
        state.alert = .deletePermanently(todoID)
        return .none
    }

    private func reduceSaveTodoForm(
        state: inout State,
        formAction: PresentationAction<TodoFormReducer.Action>
    ) -> Effect<Action> {
        guard case .presented(.delegate(.save)) = formAction else {
            return .none
        }
        guard var todoToSave = state.todoForm?.todo else {
            return .none
        }
        let addingNewTodo = state.storedTodos.contains { $0.id == todoToSave.id } == false

        let trimmedDueDate = todoToSave.dueDate?.trim(with: calendar)
        todoToSave.dueDate = trimmedDueDate
        state.storedTodos[id: todoToSave.id] = todoToSave

        state.todoForm = nil

        let addingOnCompleted = addingNewTodo && state.tab == .completed
        let addingOnTrashBin = addingNewTodo && state.tab == .trashBin
        let addingNonTodayOnToday = todoToSave.isListedFor(today: date.now, by: calendar) == false
            && state.tab == .today

        if addingOnCompleted || addingOnTrashBin || addingNonTodayOnToday {
            return .send(.delegate(.switchToPendingTab))
        } else {
            updateDisplayedTodos(on: &state)
            return .none
        }
    }

    private func reduceAlert(
        state: inout State,
        alert: PresentationAction<TodoListTabReducer.Alert>
    ) -> Effect<Action> {
        guard case .presented(.confirmPermanentDeletion(let id)) = alert else {
            return .none
        }
        state.storedTodos.remove(id: id)
        updateDisplayedTodos(on: &state)
        return .none
    }

    private func reduceTodoItem(state: inout State, action: IdentifiedActionOf<TodoItemReducer>) -> Effect<Action> {
        switch action {
        case .element(let id, let elementAction):
            if case .completionAction = elementAction {
                state.storedTodos[id: id] = state.displayedTodos[id: id]
                updateDisplayedTodos(on: &state)
            } else if case .tapAction = elementAction {
                if let todoToEdit = state.storedTodos[id: id] {
                    state.todoForm = TodoFormReducer.State(todo: todoToEdit)
                }
            }
        }
        return .none
    }

    private func reduceOnAppear(state: inout State) -> Effect<Action> {
        updateDisplayedTodos(on: &state)
        return .none
    }

    private func updateDisplayedTodos(on state: inout State) {
        let now = date.now
        var filtered = state.tab.filteredTodos(from: state.storedTodos, for: now, calendar: calendar)
        filtered.sort(by: >)
        state.displayedTodos = filtered
    }
}

// MARK: - Alert

extension AlertState where Action == TodoListTabReducer.Alert {

    static func deletePermanently(_ todoID: ToDo.ID) -> Self {
        Self {
            TextState("Delete permanently")
        } actions: {
            ButtonState(role: .destructive, action: .confirmPermanentDeletion(todoID)) {
                TextState("Yes, I'm sure")
            }
            ButtonState(role: .cancel) {
                TextState("Nevermind")
            }
        } message: {
            TextState("Do you really want to delete this item permanently?")
        }
    }
}
