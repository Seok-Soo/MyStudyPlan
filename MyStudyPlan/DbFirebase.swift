//
//  DbFirebase.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/14/25.
//

import Foundation
import FirebaseFirestore

class DbFirebase: Database {
    
    // 데이터를 저장할 Firestore 컬렉션 참조
    var reference: CollectionReference = Firestore.firestore().collection("cities")
    
    // 데이터 변화 발생 시 부모에게 알리기 위한 클로저
    var parentNotification: (([String: Any]?, DbAction?) -> Void)?
    
    // 기존 Query 리스너 등록 여부
    var existQuery: ListenerRegistration?
    
    // 생성자: 클로저를 보관
    required init(parentNotification: (([String: Any]?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
    }
    
    // 데이터 조회 범위를 설정하고, 데이터 변화 감지 시 알림
    func setQuery(from: Any, to: Any) {
        // 다음 슬라이드에서 구현 예정
    }
    
    // 데이터베이스에 변경 사항을 저장하고 부모에 알림
    func saveChange(key: String, object: [String: Any], action: DbAction) {
        // 다음 슬라이드에서 구현 예정
    }
}
