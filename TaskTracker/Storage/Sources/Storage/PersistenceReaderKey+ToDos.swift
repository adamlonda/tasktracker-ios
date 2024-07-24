import ComposableArchitecture
import Foundation
import Models
import Tagged

extension PersistenceReaderKey
    where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<ToDo>>> {

    public static var todoStorage: Self {
        PersistenceKeyDefault(.fileStorage(.documentsDirectory.appending(component: "todos.json")), [])
    }
}
