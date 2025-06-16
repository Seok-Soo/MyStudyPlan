//
//  TodoViewModel.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/16/25.
//

import Foundation

class TodoViewModel {
    var todos: [TodoItem] = []
    var db: Database!
    var onUpdate: (() -> Void)?

    init() {
        db = DbFirebase(parentNotification: { [weak self] data, action in
            self?.handleReceive(data: data, action: action)
        })

        db.setQuery(from: 0, to: 10000)
    }

    func handleReceive(data: [String: Any]?, action: DbAction?) {
        guard let data = data, let id = data["id"] as? String else { return }

        DispatchQueue.main.async {
            switch action {
            case .add:
                let todo = TodoItem(id: id,
                                    title: data["title"] as? String ?? "",
                                    isDone: data["isDone"] as? Bool ?? false)
                self.todos.append(todo)
            case .modify:
                if let index = self.todos.firstIndex(where: { $0.id == id }) {
                    self.todos[index].isDone.toggle()
                }
            case .delete:
                self.todos.removeAll { $0.id == id }
            case .none: break
            }

            self.onUpdate?()
        }
    }

    func startListening() {
        db.setQuery(from: 0, to: 10000)
    }
    
    func addTodo(title: String) {
        let id = UUID().uuidString
        let newData: [String: Any] = ["id": id, "title": title, "isDone": false]
        db.saveChange(key: id, object: newData, action: .add)
    }

    func toggleDone(for todo: TodoItem) {
        let updatedData: [String: Any] = ["id": todo.id, "title": todo.title, "isDone": !todo.isDone]
        db.saveChange(key: todo.id, object: updatedData, action: .modify)
    }

    func deleteTodo(_ todo: TodoItem) {
        db.saveChange(key: todo.id, object: [:], action: .delete)
    }
}
