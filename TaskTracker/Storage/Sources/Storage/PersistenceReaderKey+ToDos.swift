import ComposableArchitecture
import Foundation
import Models
import Tagged

extension PersistenceReaderKey
    where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<ToDo>>> {

    public static var todos: Self {
        PersistenceKeyDefault(.fileStorage(.documentsDirectory.appending(component: "todos.json")), [])
    }
}
