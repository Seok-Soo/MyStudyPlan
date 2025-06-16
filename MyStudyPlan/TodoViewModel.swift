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
    var currentDate: String = todayString() // 초기 날짜는 오늘로

    init() {
        db = DbFirebase(parentNotification: { [weak self] data, action in
            self?.handleReceive(data: data, action: action)
        })
        startListening(for: currentDate)
    }

    func startListening(for date: String) {
        currentDate = date
        db.setQuery(from: date, to: date)
    }

    func handleReceive(data: [String: Any]?, action: DbAction?) {
        print("📩 Received: \(String(describing: data)) | Action: \(String(describing: action))")
        guard let data = data,
              let id = data["id"] as? String else { return }

        let item = TodoItem(
            id: id,
            title: data["title"] as? String ?? "",
            status: data["status"] as? String ?? "시작전",
            date: data["date"] as? String ?? TodoViewModel.todayString(),
            duration: data["duration"] as? Int ?? 0
        )

        DispatchQueue.main.async {
            switch action {
            case .add:
                self.todos.append(item)
            case .modify:
                if let idx = self.todos.firstIndex(where: { $0.id == id }) {
                    self.todos[idx] = item
                }
            case .delete:
                self.todos.removeAll { $0.id == id }
            case .none:
                break
            }
            self.onUpdate?()
        }
    }

    func addTodo(item: TodoItem) {
        let data: [String: Any] = [
            "id": item.id,
            "title": item.title,
            "status": item.status,
            "date": item.date,
            "duration": item.duration
        ]
        db.saveChange(key: item.id, object: data, action: .add)
    }
    func updateStatus(for todo: TodoItem, to newStatus: String) {
        let newData: [String: Any] = [
            "id": todo.id,
            "title": todo.title,
            "status": newStatus,
            "date": todo.date,
            "duration": todo.duration
        ]
        db.saveChange(key: todo.id, object: newData, action: .modify)
    }

    func deleteTodo(_ todo: TodoItem) {
        db.saveChange(key: todo.id, object: [:], action: .delete)
    }

    // 유틸 함수
    static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
