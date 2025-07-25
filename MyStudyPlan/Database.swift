//
//  Database.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/14/25.
//

import Foundation

// Database.swift

enum DbAction {
    case add       // 데이터 추가
    case delete    // 데이터 삭제 (오타 수정: detete → delete)
    case modify    // 데이터 수정
}

protocol Database {
    // 생성자: 데이터베이스에 변경이 생기면 parentNotification를 호출하여 부모에게 알림
    init(parentNotification: (([String: Any]?, DbAction?) -> Void)?)
    
    // from ~ to 사이의 데이터를 읽고 parentNotification를 호출하여 부모에게 알림
    func setQuery(from: Any, to: Any)
    
    // 데이터베이스에 plan을 변경하고 parentNotification를 호출하여 부모에게 알림
    func saveChange(key: String, object: [String: Any], action: DbAction)
}
