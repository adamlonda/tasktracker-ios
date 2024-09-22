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
            store.send(.completionAction)
        } label: {
            Image(systemName: store.completedAt == nil ? "circle" : "checkmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }

    @ViewBuilder var todoTitle: some View {
        Text(store.title)
            .font(.body)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.listItemBackground)
            .onTapGesture { onTap() }
            .strikethrough(store.strikethrough)
            .foregroundStyle(store.foregroundStyle)
    }

    @ViewBuilder var priority: some View {
        Image(systemName: store.priority.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundStyle(store.priority.color)
            .background(Color.listItemBackground)
            .onTapGesture { onTap() }
    }

    @ViewBuilder var dueLabel: some View {
        if store.dueDate != nil {
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
                if store.recurrence != .never {
                    Image(systemName: "repeat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
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
        guard let dueDate = dueDate else {
            return ""
        }
        let calendar = Calendar.current

        if calendar.isDateInToday(dueDate) {
            return "Today"
        } else if calendar.isDateInYesterday(dueDate) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(dueDate) {
            return "Tomorrow"
        }

        let formatter = DateFormatter()
        let now = Date.now

        let dayComponents = calendar.dateComponents([.day], from: now, to: dueDate)
        if let day = dayComponents.day, 0 < day && day < 6 {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: dueDate)
        }

        let monthComponents = calendar.dateComponents([.month], from: now, to: dueDate)
        if abs(monthComponents.month ?? 0) >= 11 {
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: dueDate)
        }

        formatter.dateFormat = "dd MMM"
        return formatter.string(from: dueDate)
    }

    fileprivate var strikethrough: Bool {
        completedAt != nil
    }

    fileprivate var foregroundStyle: HierarchicalShapeStyle {
        completedAt == nil ? .primary : .secondary
    }

    fileprivate var dueLabelColor: Color {
        guard let dueDate = dueDate else {
            return .clear
        }
        guard completedAt == nil else {
            return .gray
        }
        let calendar = Calendar.current

        if calendar.isDateInToday(dueDate) || calendar.isDateInTomorrow(dueDate) {
            return .yellow
        } else if calendar.dateComponents([.day], from: .now, to: dueDate).day ?? 0 < 0 {
            return .red
        } else {
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
            .yearOverdue(from: now, title: "Year Overdue"),
            .yearOverdue(from: now, title: "Year Overdue", recurrence: .annually),
            .twoDaysOverdue(from: now, title: "Two Days Overdue"),
            .twoDaysOverdue(from: now, title: "Two Days Overdue", recurrence: .daily),
            .dueYesterday(from: now, title: "Due Yesterday"),
            .dueYesterday(from: now, title: "Due Yesterday", recurrence: .weekly),
            .mock(title: "Due Today", dueDate: now),
            .mock(title: "Due Today", dueDate: now, recurrence: .monthly),
            .dueTomorrow(from: now, title: "Due Tomorrow"),
            .dueTomorrow(from: now, title: "Due Tomorrow", recurrence: .annually),
            .dueThisWeek(from: now, title: "Due In Two Days"),
            .dueThisWeek(from: now, title: "Due In Two Days", recurrence: .daily),
            .dueNextWeek(from: now, title: "Due In Seven Days"),
            .dueNextWeek(from: now, title: "Due In Seven Days", recurrence: .weekly),
            .dueNextYear(from: now, title: "Due Next Year"),
            .dueNextYear(from: now, title: "Due Next Year", recurrence: .annually),
            .mock(title: "Very very very very very very long")
        ]
    }
}

#Preview {
    let now = Date.now
    return List {
        ForEach([ToDo].previewTodos(now: now), id: \.id) { todo in
            TodoItem(
                store: Store(initialState: todo) {
                    TodoItemReducer()
                },
                onTapUIDebug: { print("Tap action goes here for \(todo.title)") }
            )
        }
    }
}
