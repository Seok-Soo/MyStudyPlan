//
//  TodoViewController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/13/25.
//

import UIKit

class TodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!

    var viewModel = TodoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        viewModel.onUpdate = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        viewModel.startListening()
    }

    @IBAction func addTodo(_ sender: UIButton) {
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
        content.secondaryText = todo.isDone ? "✅ 완료됨" : "🕘 진행 중"
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = viewModel.todos[indexPath.row]
        viewModel.toggleDone(for: todo)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteTodo(viewModel.todos[indexPath.row])
        }
    }
}
