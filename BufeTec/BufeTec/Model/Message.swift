//
//  Message.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/26/24.
//

import Foundation
struct Message: Identifiable {
    let id = UUID()
    let avatar: String
    let senderName: String
    let time: String
    let title: String
    let description: String
    var isRead: Bool
}
