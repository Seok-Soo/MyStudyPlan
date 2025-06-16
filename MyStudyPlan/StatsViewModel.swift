//
//  StatsViewModel.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/16/25.
//

import Foundation

class StatsViewModel {
    
    private(set) var dailyStats: [(date: String, totalDuration: Int)] = []
    private let calendar = Calendar.current
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    // 외부에서 Firebase로부터 todos를 받아 처리
    func processTodos(_ todos: [TodoItem]) {
        let filtered = todos.filter { isWithinLast7Days(dateString: $0.date) }

        var grouped: [String: Int] = [:]
        for todo in filtered {
            grouped[todo.date, default: 0] += todo.duration
        }
        
        // 정렬
        dailyStats = grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
    }

    private func isWithinLast7Days(dateString: String) -> Bool {
        guard let date = formatter.date(from: dateString) else { return false }
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: Date()) else { return false }
        return date >= sevenDaysAgo && date <= Date()
    }

    func durationString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)시간 \(minutes)분"
    }
}
