//
//  TabBarController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/13/25.
//

import Foundation
// TabBarController.swift
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let todoVC = TodoViewController()
        todoVC.tabBarItem = UITabBarItem(title: "할일", image: UIImage(systemName: "checkmark.circle"), tag: 0)

//        let statsVC = StatsViewController()
//        statsVC.tabBarItem = UITabBarItem(title: "통계", image: UIImage(systemName: "chart.bar"), tag: 1)
//
//        let focusVC = FocusViewController()
//        focusVC.tabBarItem = UITabBarItem(title: "학습시작", image: UIImage(systemName: "play.circle"), tag: 2)
//
//        let scheduleVC = ScheduleViewController()
//        scheduleVC.tabBarItem = UITabBarItem(title: "일정", image: UIImage(systemName: "calendar"), tag: 3)
//
//        let settingsVC = SettingsViewController()
//        settingsVC.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gear"), tag: 4)

        viewControllers = [todoVC, statsVC, focusVC, scheduleVC, settingsVC]
    }
}
