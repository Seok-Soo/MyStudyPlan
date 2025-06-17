//
//  StatsViewController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/13/25.
//

import DGCharts
import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var scopeSegment: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!

    var viewModel = StatsViewModel()
    var allTodos: [TodoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        scopeSegment.selectedSegmentIndex = 0
        scopeSegment.addTarget(self, action: #selector(scopeChanged), for: .valueChanged)

        // Firebase에서 전체 데이터 불러오기
        DbFirebase(parentNotification: { [weak self] data, action in
            guard let self = self,
                  let data = data,
                  let id = data["id"] as? String else { return }

            let item = TodoItem(
                id: id,
                title: data["title"] as? String ?? "",
                status: data["status"] as? String ?? "시작전",
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
        viewModel.process(todos: allTodos, scope: scope)

        let labels = viewModel.groupedStats.map { $0.label }

        let entries = viewModel.groupedStats.enumerated().map { (index, stat) in
            BarChartDataEntry(x: Double(index), y: Double(stat.totalSeconds) / 60.0)
        }

        let dataSet = BarChartDataSet(entries: entries, label: "")
        dataSet.colors = [UIColor.systemIndigo]
        dataSet.valueColors = [UIColor.clear]

        let data = BarChartData(dataSet: dataSet)

        barChartView.data = data

        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelFont = .systemFont(ofSize: 13, weight: .medium)
        barChartView.xAxis.labelTextColor = .darkGray
//        barChartView.xAxis.labelRotationAngle = -20
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.granularityEnabled = true
//        barChartView.xAxis.setLabelCount(labels.count, force: true)

        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false

        barChartView.noDataText = "기록된 데이터가 없습니다"
        barChartView.animate(yAxisDuration: 0.6)

        totalLabel.text = "총 공부 시간: \(viewModel.totalTimeFormatted())"
    }
}
