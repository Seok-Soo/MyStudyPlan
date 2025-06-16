//
//  ScheduleViewController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/13/25.
//

import UIKit
import FSCalendar

class ScheduleViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!

    var allTodos: [TodoItem] = []
    var filteredTodos: [TodoItem] = []
    var selectedDate: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        calendar.delegate = self
        calendar.dataSource = self

        // ✨ 달력 외형 설정 (선택)
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.selectionColor = .systemIndigo
        calendar.appearance.todayColor = .lightGray
        calendar.appearance.titleTodayColor = .white

        tableView.delegate = self
        tableView.dataSource = self

        selectedDate = getToday()

        // 🔄 Firestore에서 Todo 불러오기
        DbFirebase(parentNotification: { [weak self] data, action in
            guard let self = self,
                  let data = data,
                  let id = data["id"] as? String else { return }

            let item = TodoItem(
                id: id,
                title: data["title"] as? String ?? "",
                status: data["status"] as? String ?? "시작전",
                date: data["date"] as? String ?? "",
                duration: data["duration"] as? Int ?? 0
            )

            self.allTodos.append(item)
            self.updateTodoList(for: self.selectedDate)
            self.calendar.reloadData()
        }).setQueryAll()
    }

    // MARK: - FSCalendar Delegate

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        selectedDate = formatter.string(from: date)
        updateTodoList(for: selectedDate)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return allTodos.contains(where: { $0.date == dateString }) ? 1 : 0
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: return .red    // 일요일
        case 7: return .blue   // 토요일
        default: return .black // 평일
        }
    }

    // MARK: - Helpers

    func updateTodoList(for date: String) {
        filteredTodos = allTodos.filter { $0.date == date }
        tableView.reloadData()
    }

    func getToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTodos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = filteredTodos[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TodoCell")
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = "\(todo.status) • \(todo.duration)분"
        return cell
    }
}
