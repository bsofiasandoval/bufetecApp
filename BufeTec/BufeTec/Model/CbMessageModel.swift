//
//  CbMessageModel.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/17/24.
//

import Foundation

struct CbMessageModel: Hashable, Identifiable{
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
}
