import UIKit

class TodoAddViewController: UIViewController {

    // MARK: - IBOutlet 연결
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var durationField: UITextField! // ✅ 추가: 공부 시간(분) 입력

    let datePicker = UIDatePicker()
    var onAddTodo: ((TodoItem) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        setupSegmentStyle()
        setupDefaultDuration()
    }

    // MARK: - 날짜 Picker
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

    // MARK: - 상태 세그먼트
    func setupSegmentStyle() {
        statusSegment.removeAllSegments()
        let statuses = ["시작전", "진행중", "완료"]
        for (index, title) in statuses.enumerated() {
            statusSegment.insertSegment(withTitle: title, at: index, animated: false)
        }
        statusSegment.selectedSegmentIndex = 0

        statusSegment.selectedSegmentTintColor = .systemBlue
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
    }

    // MARK: - 기본 공부 시간
    func setupDefaultDuration() {
        durationField.text = "60" // 분 단위로 기본값
        durationField.keyboardType = .numberPad
    }

    // MARK: - 저장
    @IBAction func didTapSave(_ sender: UIButton) {
        guard let title = titleField.text,
              let date = dateTextField.text,
              let durationText = durationField.text,
              let durationMinutes = Int(durationText),
              !title.isEmpty, !date.isEmpty else { return }

        let selectedStatus = statusSegment.titleForSegment(at: statusSegment.selectedSegmentIndex) ?? "시작전"

        let newTodo = TodoItem(
            id: UUID().uuidString,
            title: title,
            status: selectedStatus,
            date: date,
            duration: durationMinutes * 60 // ✅ 분 → 초 변환
        )

        onAddTodo?(newTodo)
        dismiss(animated: true)
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
