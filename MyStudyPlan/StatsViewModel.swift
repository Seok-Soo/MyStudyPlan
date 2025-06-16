//
//  StatsViewModel.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/16/25.
//

import Foundation

enum StatsScope {
    case week, month
}

class StatsViewModel {
    private let calendar = Calendar.current
    private let formatter = DateFormatter()
    
    private(set) var groupedStats: [(label: String, totalSeconds: Int)] = []
    
    init() {
        formatter.dateFormat = "yyyy-MM-dd"
    }

    func process(todos: [TodoItem], scope: StatsScope) {
        groupedStats = []

        let validTodos = todos.compactMap { item -> (date: Date, duration: Int)? in
            guard let date = formatter.date(from: item.date) else { return nil }
            return (date: date, duration: item.duration)
        }

        let filtered = validTodos.filter { entry in
            switch scope {
            case .week:
                return calendar.isDate(entry.date, equalTo: Date(), toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(entry.date, equalTo: Date(), toGranularity: .month)
            }
        }

        var grouped: [String: Int] = [:]

        for (date, duration) in filtered {
            let label = scope == .week
                ? weekdayLabel(from: date)
                : weekOfMonthLabel(from: date)
            grouped[label, default: 0] += duration
        }

        if scope == .week {
            let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
            groupedStats = weekdays.map { label in
                (label: label, totalSeconds: grouped[label, default: 0])
            }
        } else {
            // ⚠️ 실제 존재하는 주차만 추출
            let sortedLabels = grouped.keys.sorted { $0 < $1 } // "1주차", "2주차", ...
            groupedStats = sortedLabels.map { label in
                (label: label, totalSeconds: grouped[label] ?? 0)
            }
        }
    }


    private func weekdayLabel(from date: Date) -> String {
        let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
        let weekday = calendar.component(.weekday, from: date)
        return weekdaySymbols[weekday - 1]
    }

    private func weekOfMonthLabel(from date: Date) -> String {
        let week = calendar.component(.weekOfMonth, from: date)
        return "\(week)주차"
    }

    private func numberOfWeeksInCurrentMonth() -> Int {
        let today = Date()
        guard let range = calendar.range(of: .weekOfMonth, in: .month, for: today) else { return 0 }
        return range.count
    }

    func totalTimeFormatted() -> String {
        let total = groupedStats.map { $0.totalSeconds }.reduce(0, +)
        let hours = total / 3600
        let mins = (total % 3600) / 60
        return "\(hours)시간 \(mins)분"
    }
}
