//
//  UserData.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/26/24.
//

import Foundation

struct UserData {
    var id: String
    var name: String
    var email: String?
    var userType: UserType
    var phoneNumber: String?
    
    // Lawyer-specific fields
    var cedulaProfesional: String?
    var especialidad: String?
    var yearsOfExperience: Int?
    
    // Client-specific fields
    var clientId: String?
    
    enum UserType: String, Codable {
        case lawyer
        case becario
        case client
    }
}
