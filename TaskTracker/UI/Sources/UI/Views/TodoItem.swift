import ComposableArchitecture
import Models
import Reducers
import SwiftUI

struct TodoItem: View {

    @Bindable var store: StoreOf<TodoItemReducer>

    var onTapUIDebug = {}

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: .medium) {
            checkButton
            priority
            todoTitle
            dueLabel
                .layoutPriority(1)
        }
    }

    // MARK: - Subviews

    @ViewBuilder var checkButton: some View {
        Button {
            store.send(.toggleCompletionAction)
        } label: {
            Image(systemName: store.todo.completedAt == nil ? "circle" : "checkmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }

    @ViewBuilder var todoTitle: some View {
        Text(store.todo.title)
            .font(.body)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.listItemBackground)
            .onTapGesture { onTap() }
            .strikethrough(store.strikethrough)
            .foregroundStyle(store.foregroundStyle)
    }

    @ViewBuilder var priority: some View {
        Image(systemName: store.todo.priority.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundStyle(store.todo.priority.color)
            .background(Color.listItemBackground)
            .onTapGesture { onTap() }
    }

    @ViewBuilder var dueLabel: some View {
        if store.dueLabel != nil {
            HStack(alignment: .center, spacing: .xxSmall) {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(store.dueLabelText)
                    .lineLimit(1)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .strikethrough(store.strikethrough)
            }
            .padding(.xxSmall)
            .background(store.dueLabelColor.opacity(0.3))
            .onTapGesture { onTap() }
            .foregroundStyle(store.foregroundStyle)
        }
    }

    private func onTap() {
        store.send(.tapAction)
        onTapUIDebug()
    }
}

// MARK: - Due Date Labels

extension TodoItemReducer.State {
    fileprivate var dueLabelText: String {
        guard let dueDate = todo.dueDate, let dueLabel = dueLabel else {
            return ""
        }
        let formatter = DateFormatter()
        switch dueLabel {
        case .today:
            return "Today"
        case .yesterday:
            return "Yesterday"
        case .tomorrow:
            return "Tomorrow"
        case .thisWeek:
            formatter.dateFormat = "EEEE"
            return formatter.string(from: dueDate)
        case .nextWeekAndBeyond, .overdue:
            formatter.dateFormat = "dd MMM"
            return formatter.string(from: dueDate)
        }
    }

    fileprivate var strikethrough: Bool {
        todo.completedAt != nil
    }

    fileprivate var foregroundStyle: HierarchicalShapeStyle {
        todo.completedAt == nil ? .primary : .secondary
    }

    fileprivate var dueLabelColor: Color {
        guard let dueLabel = dueLabel else {
            return .clear
        }
        guard todo.completedAt == nil else {
            return .gray
        }
        switch dueLabel {
        case .yesterday, .overdue:
            return .red
        case .today, .tomorrow:
            return .yellow
        case .thisWeek, .nextWeekAndBeyond:
            return .gray
        }
    }
}

// MARK: - Preview

extension [ToDo] {
    fileprivate static func previewTodos(now: Date) -> Self {
        [
            .highPriority,
            .normalPriority,
            .lowPriority,
            .mock(title: "Two Days Overdue", dueDate: now.addingTimeInterval(-2 * 24 * 60 * 60)),
            .mock(title: "Due Yesterday", dueDate: now.addingTimeInterval(-24 * 60 * 60)),
            .mock(title: "Due Today", dueDate: now),
            .mock(title: "Due Tomorrow", dueDate: now.addingTimeInterval(24 * 60 * 60)),
            .mock(title: "Due In Two Days", dueDate: now.addingTimeInterval(2 * 24 * 60 * 60)),
            .mock(title: "Due In Seven Days", dueDate: now.addingTimeInterval(7 * 24 * 60 * 60)),
            .mock(title: "Very very very very very very long")
        ]
    }
}

#Preview {
    let now = Date.now
    return List {
        ForEach([ToDo].previewTodos(now: now), id: \.id) { todo in
            TodoItem(
                store: Store(
                    initialState: .init(
                        todo: todo,
                        dueLabel: todo.dueLabel(calendar: .current, now: now)
                    )
                ) {
                    TodoItemReducer()
                },
                onTapUIDebug: { print("Tap action goes here for \(todo.title)") }
            )
        }
    }
}
