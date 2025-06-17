//
//  TodoViewController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/13/25.
//

import UIKit

class TodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    var currentDate: Date = Date()
    var viewModel = TodoViewModel()

    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd.EEE"
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none  // ✅ 셀 구분선 제거

        viewModel.onUpdate = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        updateDateLabel()
        viewModel.startListening(for: dateString(from: currentDate))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        addButton.clipsToBounds = true
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        addButton.tintColor = .white
        addButton.backgroundColor = .systemIndigo
    }

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
            if let sheet = addVC.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in return UIScreen.main.bounds.height })]
                sheet.prefersGrabberVisible = false
            }
            addVC.onAddTodo = { [weak self] newTodo in
                self?.viewModel.addTodo(item: newTodo)
            }
            present(addVC, animated: true)
        }
    }

    // MARK: - UITableView 구성

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.todos.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1  // 각 섹션에 셀 하나
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16  // 셀 위 여백
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()  // 투명 헤더 뷰
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8  // 셀 아래 여백
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // ✅ 셀 배경 + 둥근 모서리
        let margin: CGFloat = 16
        let bgView = UIView(
            frame: CGRect(x: margin, y: 0, width: tableView.bounds.width - margin * 2, height: cell.bounds.height)
        )
        bgView.backgroundColor = UIColor(red: 37/255, green: 56/255, blue: 71/255, alpha: 1.0)
        bgView.layer.cornerRadius = 10
        cell.backgroundView = bgView
        cell.backgroundColor = .clear
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = viewModel.todos[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = todo.title
        content.secondaryText = "상태: \(todo.status)"
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .white
        content.textProperties.font = .systemFont(ofSize: 18, weight: .semibold)
        content.secondaryTextProperties.font = .systemFont(ofSize: 14)

        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = viewModel.todos[indexPath.section]
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
            let todo = viewModel.todos[indexPath.section]
            viewModel.deleteTodo(todo)
        }
    }
}
