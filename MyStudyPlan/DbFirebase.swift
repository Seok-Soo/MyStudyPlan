//
//  DbFirebase.swift
//  MyStudyPlan
//
//  Created by 석종수 on 6/14/25.
//

import Foundation
import FirebaseFirestore

class DbFirebase: Database {
    var reference: CollectionReference = Firestore.firestore().collection("todos")
    var parentNotification: (([String: Any]?, DbAction?) -> Void)?
    var existQuery: ListenerRegistration?

    required init(parentNotification: (([String: Any]?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
    }

    func setQuery(from: Any, to: Any) {
        if let query = existQuery {
            query.remove()
        }

        // 예: 특정 날짜 필터링
        guard let date = from as? String else { return }
        let query = reference.whereField("date", isEqualTo: date)
        existQuery = query.addSnapshotListener(onChangingData)
    }

    func saveChange(key: String, object: [String: Any], action: DbAction) {
        if action == .delete {
            reference.document(key).delete()
            return
        }
        reference.document(key).setData(object)
    }

    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnapshot = querySnapshot else { return }
        if querySnapshot.documentChanges.isEmpty { return }

        for documentChange in querySnapshot.documentChanges {
            let dict = documentChange.document.data()
            var action: DbAction?

            switch documentChange.type {
            case .added:
                action = .add
            case .modified:
                action = .modify
            case .removed:
                action = .delete
            }

            parentNotification?(dict, action)
        }
    }
}
