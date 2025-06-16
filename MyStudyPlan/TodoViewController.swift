//
//  TodoViewController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/13/25.
//

import UIKit

class TodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet 연결
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - 날짜 관련
    var currentDate: Date = Date()
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd.EEE"
        return f
    }()
    
    // MARK: - 뷰모델
    var viewModel = TodoViewModel()

    // MARK: - 생명 주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel.onUpdate = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        updateDateLabel()
        viewModel.startListening(for: dateString(from: currentDate))
    }

    // MARK: - 날짜 이동 액션
    @IBAction func didTapPrevDate(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        updateDateLabel()
        viewModel.startListening(for: dateString(from: currentDate))
    }
    
    @IBAction func didTapNextDate(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        updateDateLabel()
        viewModel.startListening(for: dateString(from: currentDate))
    }
    
    func updateDateLabel() {
        dateLabel.text = formatter.string(from: currentDate)
    }
    
    func dateString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    // MARK: - 할 일 추가
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let text = textField.text, !text.isEmpty else { return }
        viewModel.addTodo(title: text)
        textField.text = ""
    }

    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = viewModel.todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = todo.title
        content.secondaryText = "상태: \(todo.status)"
        cell.contentConfiguration = content
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = viewModel.todos[indexPath.row]
        let nextStatus = nextStatusFor(current: todo.status)
        viewModel.updateStatus(for: todo, to: nextStatus)
    }
    
    func nextStatusFor(current: String) -> String {
        switch current {
        case "시작전": return "진행중"
        case "진행중": return "완료"
        default: return "시작전"
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todo = viewModel.todos[indexPath.row]
            viewModel.deleteTodo(todo)
        }
    }
}
