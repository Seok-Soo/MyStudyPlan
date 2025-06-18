//
//  StatsViewController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/13/25.
//

import DGCharts
import UIKit

class BarChartValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let totalMinutes = Int(value.rounded())
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(minutes)분"
        }
    }
}

class StatsViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var scopeSegment: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var compareLabel: UILabel!

    var viewModel = StatsViewModel()
    var allTodos: [TodoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        scopeSegment.selectedSegmentIndex = 0
        scopeSegment.addTarget(self, action: #selector(scopeChanged), for: .valueChanged)

        DbFirebase(parentNotification: { [weak self] data, action in
            guard let self = self,
                  let data = data,
                  let id = data["id"] as? String else { return }

            let item = TodoItem(
                id: id,
                title: data["title"] as? String ?? "",
                status: data["status"] as? String ?? "완료",
                date: data["date"] as? String ?? "",
                duration: data["duration"] as? Int ?? 0
            )

            self.allTodos.append(item)
            DispatchQueue.main.async {
                self.updateChart()
            }
        }).setQueryAll()
    }

    @objc func scopeChanged() {
        updateChart()
    }

    func updateChart() {
        let scope: StatsScope = (scopeSegment.selectedSegmentIndex == 0) ? .week : .month
        
        let filteredTodos = allTodos.filter { $0.status == "완료" }
        viewModel.process(todos: filteredTodos, scope: scope)

        let labels = viewModel.groupedStats.map { $0.label }

        let entries = viewModel.groupedStats.enumerated().map { (index, stat) in
            BarChartDataEntry(x: Double(index), y: Double(stat.totalSeconds) / 60.0)
        }

        let dataSet = BarChartDataSet(entries: entries, label: "")
        dataSet.colors = [UIColor(red: 37/255, green: 56/255, blue: 71/255, alpha: 1.0)]
        dataSet.valueFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        dataSet.valueTextColor = .white
        dataSet.valueFormatter = BarChartValueFormatter()

        let data = BarChartData(dataSet: dataSet)
        barChartView.data = data

        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelFont = .systemFont(ofSize: 13, weight: .medium)
        barChartView.xAxis.labelTextColor = .white
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.granularityEnabled = true

        barChartView.leftAxis.labelTextColor = .white
        barChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 12)
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.leftAxis.gridColor = UIColor.gray.withAlphaComponent(0.2)
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.granularity = 120
        
        barChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(block: { (value, axis) -> String in
            let totalMinutes = Int(value.rounded())
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            if hours > 0 && minutes > 0 {
                return "\(hours)시간 \(minutes)분"
            } else if hours > 0 {
                return "\(hours)시간"
            } else {
                return "\(minutes)분"
            }
        })

        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false
        barChartView.noDataText = "기록된 데이터가 없습니다"
        barChartView.animate(yAxisDuration: 0.6)

        totalLabel.text = "총 공부 시간: \(viewModel.totalTimeFormatted())"

        let diff: Int
        if scope == .week {
            diff = viewModel.compareDay(offset: 0) - viewModel.compareDay(offset: -1)
        } else {
            diff = viewModel.compareWeek(offset: 0) - viewModel.compareWeek(offset: -1)
        }

        
        if diff == 0 {
            compareLabel.text = ""
        } else if diff > 0 {
            compareLabel.textColor = .systemGreen
            compareLabel.text = "+\(formatDuration(seconds: diff)) 증가"
        } else {
            compareLabel.textColor = .systemRed
            compareLabel.text = "-\(formatDuration(seconds: abs(diff))) 감소"
        }
    }

    func formatDuration(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else if minutes > 0 {
            return "\(minutes)분"
        } else {
            return "0분"
        }
    }
}
