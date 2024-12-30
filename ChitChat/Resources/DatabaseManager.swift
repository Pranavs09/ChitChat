//
//  DatabaseManager.swift
//  ChitChat
//
//  Created by Pranav Sharma on 2024-12-29.
//

import FirebaseDatabase
import Foundation

final class DatabaseManager {
    static let shared = DatabaseManager()

    private let database = Database.database().reference()

}

//Mark: - Account Management

extension DatabaseManager {

    public func userExist(
        with emailAddress: String, completion: @escaping (Bool) -> Void
    ) {
        database.child(emailAddress).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }

    ///inserts new users to database
    public func insertUser(with user: chatAppUser) {
        database.child(user.emailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ])
    }
}

struct chatAppUser: Codable {
    let firstName: String
    let lastName: String
    let emailAddress: String
    //    let profilePictureUrl: String
}
