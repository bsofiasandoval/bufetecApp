//
//  TypingNavigationView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/14/24.
//

import SwiftUI

struct TypingAnimationView: View {
    @State private var showFirstDot = false
    @State private var showSecondDot = false
    @State private var showThirdDot = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .scaleEffect(getScale(for: index))
                    .animation(getAnimation(for: index), value: getAnimationValue(for: index))
            }
        }
        .padding(10)
        .background(Color.botMessageBackground)
        .clipShape(BubbleShape(isFromCurrentUser: false))
        .onAppear {
            animateDots() 
        }
    }
    
    private func getScale(for index: Int) -> CGFloat {
        switch index {
        case 0: return showFirstDot ? 1 : 0.5
        case 1: return showSecondDot ? 1 : 0.5
        case 2: return showThirdDot ? 1 : 0.5
        default: return 0.5
        }
    }
    
    private func getAnimation(for index: Int) -> Animation {
        Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)
            .repeatForever()
            .delay(Double(index) * 0.2)
    }
    
    private func getAnimationValue(for index: Int) -> Bool {
        switch index {
        case 0: return showFirstDot
        case 1: return showSecondDot
        case 2: return showThirdDot
        default: return false
        }
    }
    
    private func animateDots() {
        withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5).repeatForever()) {
            showFirstDot.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5).repeatForever()) {
                showSecondDot.toggle()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5).repeatForever()) {
                showThirdDot.toggle()
            }
        }
    }
}
