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

        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let reportVC = StatsViewController()
        reportVC.tabBarItem = UITabBarItem(title: "Report", image: UIImage(systemName: "book"), tag: 1)

        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)

        viewControllers = [homeVC, reportVC, settingsVC]
    }
}
