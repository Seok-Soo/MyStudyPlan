import UIKit

class TodoAddViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var durationPicker: UIPickerView!

    var onAddTodo: ((TodoItem) -> Void)?

    // 날짜 Picker 관련
    let years = Array(2000...2100)
    let months = Array(1...12)
    var days: [Int] = Array(1...31)

    var selectedYear = Calendar.current.component(.year, from: Date())
    var selectedMonth = Calendar.current.component(.month, from: Date())
    var selectedDay = Calendar.current.component(.day, from: Date())

    // 시간 Picker 관련
    var selectedHour = 0
    var selectedMin = 0
    var selectedSec = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentStyle()
        setupDatePicker()
        setupDurationPicker()
    }

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

    func setupDatePicker() {
        datePickerView.delegate = self
        datePickerView.dataSource = self

        if let yIndex = years.firstIndex(of: selectedYear) {
            datePickerView.selectRow(yIndex, inComponent: 0, animated: false)
        }
        datePickerView.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
        datePickerView.selectRow(selectedDay - 1, inComponent: 2, animated: false)
    }

    func setupDurationPicker() {
        durationPicker.delegate = self
        durationPicker.dataSource = self
        durationPicker.selectRow(1, inComponent: 0, animated: false)
        selectedHour = 1
    }

    func dateFromSelection() -> Date {
        let components = DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)
        return Calendar.current.date(from: components) ?? Date()
    }

    @IBAction func didTapSave(_ sender: UIButton) {
        guard let title = titleField.text, !title.isEmpty else { return }

        let selectedStatus = statusSegment.titleForSegment(at: statusSegment.selectedSegmentIndex) ?? "시작전"
        let totalSeconds = selectedHour * 3600 + selectedMin * 60 + selectedSec

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: dateFromSelection())

        let newTodo = TodoItem(
            id: UUID().uuidString,
            title: title,
            status: selectedStatus,
            date: dateString,
            duration: totalSeconds
        )

        onAddTodo?(newTodo)
        dismiss(animated: true)
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension TodoAddViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == datePickerView {
            switch component {
            case 0: return years.count
            case 1: return months.count
            case 2: return days.count
            default: return 0
            }
        } else {
            switch component {
            case 0: return 24
            case 1: return 60
            case 2: return 60
            default: return 0
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 90
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var text = ""
        let isDate = pickerView == datePickerView
        let selectedRow = pickerView.selectedRow(inComponent: component)

        if isDate {
            switch component {
            case 0: text = "\(years[row])년"
            case 1: text = "\(months[row])월"
            case 2: text = "\(days[row])일"
            default: break
            }
        } else {
            switch component {
            case 0: text = "\(row) 시간"
            case 1: text = "\(row) 분"
            case 2: text = "\(row) 초"
            default: break
            }
        }

        let color: UIColor = (row == selectedRow) ? .white : .lightGray
        return NSAttributedString(string: text, attributes: [.foregroundColor: color])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePickerView {
            switch component {
            case 0: selectedYear = years[row]
            case 1: selectedMonth = months[row]
            case 2: selectedDay = days[row]
            default: break
            }

            let date = dateFromSelection()
            let range = Calendar.current.range(of: .day, in: .month, for: date) ?? 1..<32
            days = Array(range)
            datePickerView.reloadComponent(2)
        } else {
            switch component {
            case 0: selectedHour = row
            case 1: selectedMin = row
            case 2: selectedSec = row
            default: break
            }
        }

        pickerView.reloadAllComponents() // 선택된 항목 스타일 갱신
    }
}
