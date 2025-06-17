import UIKit

class TodoAddViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var durationPicker: UIPickerView!

    var onAddTodo: ((TodoItem) -> Void)?

    // 날짜 선택용
    let years = Array(2000...2100)
    let months = Array(1...12)
    var days: [Int] = Array(1...31)

    var selectedYear = Calendar.current.component(.year, from: Date())
    var selectedMonth = Calendar.current.component(.month, from: Date())
    var selectedDay = Calendar.current.component(.day, from: Date())

    // 시간 선택용
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

        // 초기 선택
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
        guard let title = titleField.text,
              !title.isEmpty else { return }

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

// MARK: - PickerView
extension TodoAddViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == datePickerView {
            return 3 // 년, 월, 일
        } else {
            return 3 // 시, 분, 초
        }
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
        return 100
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == datePickerView {
            switch component {
            case 0: return "\(years[row])년"
            case 1: return "\(months[row])월"
            case 2: return "\(days[row])일"
            default: return nil
            }
        } else {
            switch component {
            case 0: return "\(row) 시간"
            case 1: return "\(row) 분"
            case 2: return "\(row) 초"
            default: return nil
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePickerView {
            switch component {
            case 0: selectedYear = years[row]
            case 1: selectedMonth = months[row]
            case 2: selectedDay = days[row]
            default: break
            }

            // 일 수 재계산
            let date = dateFromSelection()
            if let range = Calendar.current.range(of: .day, in: .month, for: date) {
                days = Array(range)
            } else {
                days = Array(1...31)
            }
            datePickerView.reloadComponent(2)
        } else {
            switch component {
            case 0: selectedHour = row
            case 1: selectedMin = row
            case 2: selectedSec = row
            default: break
            }
        }
    }
}
