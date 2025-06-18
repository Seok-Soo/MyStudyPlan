//
//  SettingsViewController.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/13/25.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let sections = ["일반", "알림", "데이터", "기타"]
    let items = [
        ["시작 요일 설정", "다크 모드", "언어 설정"],
        ["알림 설정"],
        ["백업 및 복원", "통계 초기화"],
        ["문의하기", "버전 정보"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "설정"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor(red: 20/255, green: 30/255, blue: 45/255, alpha: 1.0)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 20/255, green: 30/255, blue: 45/255, alpha: 1.0)

        view.backgroundColor = UIColor(red: 20/255, green: 30/255, blue: 45/255, alpha: 1.0)
        
        tableView.alwaysBounceVertical = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .white
            header.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        let title = items[indexPath.section][indexPath.row]
        cell.textLabel?.text = title
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.accessoryType = .disclosureIndicator

        if let image = iconForTitle(title) {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            cell.imageView?.image = image.withConfiguration(config).withTintColor(.systemTeal, renderingMode: .alwaysOriginal)
        }

        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 37/255, green: 56/255, blue: 71/255, alpha: 1.0)
        bgView.layer.cornerRadius = 12
        bgView.layer.masksToBounds = true
        cell.backgroundView = bgView

        let selectedBg = UIView()
        selectedBg.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.3)
        selectedBg.layer.cornerRadius = 12
        selectedBg.layer.masksToBounds = true
        cell.selectedBackgroundView = selectedBg

        cell.backgroundColor = .clear  // ✅ 흰색 모서리 방지

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = items[indexPath.section][indexPath.row]
        showAlert(title: title)
    }

    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: "이 기능은 준비 중입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func iconForTitle(_ title: String) -> UIImage? {
        switch title {
        case "시작 요일 설정": return UIImage(systemName: "calendar")
        case "다크 모드": return UIImage(systemName: "moon.fill")
        case "언어 설정": return UIImage(systemName: "globe")
        case "알림 설정": return UIImage(systemName: "bell.fill")
        case "백업 및 복원": return UIImage(systemName: "icloud.and.arrow.up")
        case "통계 초기화": return UIImage(systemName: "arrow.counterclockwise")
        case "문의하기": return UIImage(systemName: "envelope")
        case "버전 정보": return UIImage(systemName: "info.circle")
        default: return nil
        }
    }
}
