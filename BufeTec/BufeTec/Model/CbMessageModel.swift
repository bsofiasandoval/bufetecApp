//
//  CbMessageModel.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/17/24.
//

import Foundation

struct CbMessageModel: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
    let citations: [Citation]?
}

struct Citation: Identifiable, Equatable {
    let id = UUID()
    let fileName: String
    let url: String
}
