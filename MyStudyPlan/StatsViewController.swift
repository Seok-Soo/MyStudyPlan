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

        DbFirebase(parentNotification: { [weak self] data, action in
            guard let self = self, let data = data, let id = data["id"] as? String else { return }

            let item = TodoItem(
                id: id,
                title: data["title"] as? String ?? "",
                status: data["status"] as? String ?? "시작전",
                date: data["date"] as? String ?? "",
                duration: data["duration"] as? Int ?? 0
            )

            self.allTodos.append(item)
            self.updateChart()
        }).setQueryAll()
    }

    @objc func scopeChanged() {
        updateChart()
    }

    func updateChart() {
        let scope: StatsScope = (scopeSegment.selectedSegmentIndex == 0) ? .week : .month
        viewModel.process(todos: allTodos, scope: scope)

        let entries = viewModel.groupedStats.enumerated().map { (index, stat) in
            return BarChartDataEntry(x: Double(index), y: Double(stat.totalSeconds) / 60.0)
        }

        let dataSet = BarChartDataSet(entries: entries)
        dataSet.label = "공부 시간 (분)"
        dataSet.colors = [.systemBlue]

        let data = BarChartData(dataSet: dataSet)
        data.setValueFont(.systemFont(ofSize: 12))
        barChartView.data = data
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: viewModel.groupedStats.map { $0.label })
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.granularity = 1
        barChartView.notifyDataSetChanged()

        totalLabel.text = "총 공부 시간: \(viewModel.totalTimeFormatted())"
    }
}
