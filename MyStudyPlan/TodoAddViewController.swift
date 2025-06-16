//
//  TodoAddViewController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/16/25.
//

import UIKit

class TodoAddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - IBOutlet 연결
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var statusPicker: UIPickerView!
    
    // 상태 목록
    let statuses = ["시작전", "진행중", "완료"]
    
    // 부모로 전달할 콜백
    var onAddTodo: ((TodoItem) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PickerView 연결
        statusPicker.dataSource = self
        statusPicker.delegate = self
        
        // 날짜 설정
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
    }

    // MARK: - 저장 액션
    @IBAction func didTapSave(_ sender: UIButton) {
        guard let title = titleField.text, !title.isEmpty else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: datePicker.date)

        let selectedRow = statusPicker.selectedRow(inComponent: 0)
        let selectedStatus = statuses[selectedRow]

        let newTodo = TodoItem(
            id: UUID().uuidString,
            title: title,
            status: selectedStatus,
            date: dateString,
            duration: 3600 // 기본값: 1시간
        )

        onAddTodo?(newTodo)
        dismiss(animated: true)
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }
}
