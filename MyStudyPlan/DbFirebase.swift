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
        if let query = existQuery{ // 이미 퀴리가 있으면 삭제한다
        query.remove()
        }
        // 새로운 쿼리를 설정한다. 원하는 필드, 원하는 데이터를 적절히 설정하면 된다
        let query = reference.whereField("id", isGreaterThanOrEqualTo: 0).whereField("id", isLessThanOrEqualTo: 10000)
        // 쿼리를 set하는 것이 아니라 add한다는 것을 알아야 한다.
        // query를 만족하는 데이터가 발생하면 onChangingData()함수를 호출하라는 것임
        existQuery = query.addSnapshotListener(onChangingData)
    }
    
    // 데이터베이스에 변경 사항을 저장하고 부모에 알림
    func saveChange(key: String, object: [String: Any], action: DbAction) {
        if action == .delete{
        reference.document(key).delete()
        return
        }
        // key에 대한 데이터가 이미 있으면 overwrite, 없으면 insert
        reference.document(key).setData(object)
    }
    
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        // 이것은 setQuery의 결과로 호출된다.
        // 당연히 별도 스레드에서 실행되므로 GUI를 직접 변경하면 안 된다.

        guard let querySnapshot = querySnapshot else { return } // 이 경우는 거의 발생하지 않음

        // 쿼리 결과가 없을 경우 처리
        if querySnapshot.documentChanges.count == 0 {
            return
        }

        // 쿼리를 만족하는 데이터가 많을 경우 여러 변경사항이 한꺼번에 전달됨
        for documentChange in querySnapshot.documentChanges {
            let dict = documentChange.document.data() // 변경된 문서의 데이터 추출
            var action: DbAction?

            // Firestore의 변경 타입을 DbAction으로 변환
            switch documentChange.type {
            case .added:
                action = .add
            case .modified:
                action = .modify
            case .removed:
                action = .delete // 오타 수정: .detete → .delete
            }

            // 부모에게 변경 사항 전달
            parentNotification?(dict, action)
        }
    }

}
