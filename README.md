# TaskTracker

## 💡 Motivation

The main intention behind creating this app is a further practice of the [Composable Architecture](https://www.pointfree.co/collections/composable-architecture) on iOS.

Specific features of this to-do list app will be based on following ChatGPT-generated assignment:

### Objective

Create a To-Do List app using the Composable Architecture (TCA). The app should allow users to add, edit, delete, and mark to-do items as completed. Additionally, the app should allow users to filter to-do items by their completion status (All, Completed, Pending).

### Features

1. **Add To-Do Item ✅**
* The user should be able to add a new to-do item with a title and description.
2. **Edit To-Do Item**
* The user should be able to edit the title and description of an existing to-do item.
3. **Delete To-Do Item ✅**
* The user should be able to delete a to-do item.
4. **Mark To-Do Item as Completed**
* The user should be able to mark a to-do item as completed or pending.
5. **Filter To-Do Items**
* The user should be able to filter the to-do items by All, Completed, and Pending.
6. **Persist To-Do Items ✅**
* Use local storage to persist to-do items between app launches (e.g., using UserDefaults or local file storage).

## 🔨 Targeting & build

* iOS 17.5
* Xcode 15.4 (15F31d)
* Swift 5.10

## 🧩 Modules

* `Models` - Data structures to work with & its mocks
* `Storage` - Storage extensions to be used
* `Reducers` - Reducers & unit tests
* `UI` - SwiftUI views, previews & unified sizing

## 📦 Third-party Dependencies

* [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
* [SwiftLint](https://github.com/realm/SwiftLint)
* [Tagged](https://github.com/pointfreeco/swift-tagged)