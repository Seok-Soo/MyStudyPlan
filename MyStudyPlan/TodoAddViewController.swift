import UIKit

class TodoAddViewController: UIViewController {

    // MARK: - IBOutlet 연결
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var statusSegment: UISegmentedControl!

    // 내부 datePicker
    let datePicker = UIDatePicker()

    // 콜백
    var onAddTodo: ((TodoItem) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        setupSegmentStyle()
    }

    // MARK: - 날짜 Picker 설정
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        dateTextField.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneDatePicker))
        ]
        dateTextField.inputAccessoryView = toolbar
    }

    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }

    // MARK: - 세그먼트 스타일 설정
    func setupSegmentStyle() {
        statusSegment.removeAllSegments()
        let statuses = ["시작전", "진행중", "완료"]
        for (index, title) in statuses.enumerated() {
            statusSegment.insertSegment(withTitle: title, at: index, animated: false)
        }
        statusSegment.selectedSegmentIndex = 0

        // 선택된 항목 스타일
        statusSegment.selectedSegmentTintColor = .systemBlue
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
    }

    // MARK: - 저장
    @IBAction func didTapSave(_ sender: UIButton) {
        guard let title = titleField.text,
              let date = dateTextField.text,
              !title.isEmpty, !date.isEmpty else { return }

        let selectedStatus = statusSegment.titleForSegment(at: statusSegment.selectedSegmentIndex) ?? "시작전"

        let newTodo = TodoItem(
            id: UUID().uuidString,
            title: title,
            status: selectedStatus,
            date: date,
            duration: 3600 // 기본값: 1시간
        )

        onAddTodo?(newTodo)
        dismiss(animated: true)
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
	
