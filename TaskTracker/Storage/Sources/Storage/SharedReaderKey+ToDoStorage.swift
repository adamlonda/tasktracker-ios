import ComposableArchitecture
import Foundation
import Models
import Tagged

extension SharedReaderKey
    where Self == AppStorageKey<IdentifiedArrayOf<ToDo>> {

    public static func todoStorage(store: UserDefaults? = nil) -> Self {
        .appStorage("todos", store: store)
    }

    public static var todoStorage: Self {
        .todoStorage()
    }
}
