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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!  // ✅ 추가: 동그란 버튼 연결

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

    // ✅ 추가: 버튼을 동그랗게
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        addButton.clipsToBounds = true
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        addButton.tintColor = .white
        addButton.backgroundColor = .systemIndigo
    }

    // MARK: - 날짜 이동 액션
    @IBAction func didTapPrevDate(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        updateDateLabel()
        
        viewModel.todos = []
        tableView.reloadData()
        
        viewModel.startListening(for: dateString(from: currentDate))
    }

    @IBAction func didTapNextDate(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        updateDateLabel()
        
        viewModel.todos = []
        tableView.reloadData()
        
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

    @IBAction func didTapAddButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addVC = storyboard.instantiateViewController(withIdentifier: "TodoAddViewController") as? TodoAddViewController {

            // ✅ iOS 기본 Bottom Sheet 스타일
            if let sheet = addVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }

            addVC.onAddTodo = { [weak self] newTodo in
                self?.viewModel.addTodo(item: newTodo)
            }
            present(addVC, animated: true)
        }
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
