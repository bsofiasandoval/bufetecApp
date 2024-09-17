//
//  GenCBView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

struct GenCbView: View {
    @State private var isInternalUser: Bool = true
       var body: some View {
           if isInternalUser {
               InternalCbView()
           } else {
               NewClientCbView()
           }
       }
}

#Preview {
    GenCbView()
}
