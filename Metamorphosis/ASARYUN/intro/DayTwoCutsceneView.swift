//
//  DayTwoCutsceneView.swift
//  Metamorphosis
//
//  Created by Ezekiel Walfred on 25/09/26.
//


import SwiftUI

struct DayTwoCutsceneView: View {
    @Binding var currentDay: Int
    @State private var shakeOffset: CGFloat = -5.0
    @State private var showDialog = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Cocoon Asset
            Image("Cocoon")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(x: shakeOffset)
                .animation(Animation.linear(duration: 0.05).repeatForever(autoreverses: true), value: shakeOffset)
                .onAppear {
                    shakeOffset = 5.0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showDialog = true
                        }
                    }
                }
            
            if showDialog {
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Why is it dark, why am i feeling sleepy....")
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                // Evolve and jump to Day 3
                                currentDay = 3
                            }) {
                                Text("Next")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .padding(24)
                    .padding(.bottom, 40)
                }
                .transition(.opacity)
            }
        }
    }
}
