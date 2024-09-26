//
//  UserData.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/26/24.
//

import Foundation

struct UserData {
    let id: String
    let name: String
    let email: String
    let userType: UserType
    let phoneNumber: String?
    
    // Lawyer-specific fields
    let cedulaProfesional: String?
    let especialidad: String?
    let yearsOfExperience: Int?
    
    // Client-specific fields
    let clientId: String?
    
    enum UserType {
        case lawyer
        case client
    }
}
