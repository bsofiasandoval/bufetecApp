//
//  BufeTecAppWidgetBundle.swift
//  BufeTecAppWidget
//
//  Created by Sofia Sandoval on 10/16/24.
//

import WidgetKit
import SwiftUI

@main
struct BufeTecAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        BufeTecAppWidget()
        BufeTecAppWidgetControl()
        BufeTecAppWidgetLiveActivity()
    }
}
