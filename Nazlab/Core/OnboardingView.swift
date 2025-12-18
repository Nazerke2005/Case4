//
//  OnboardingView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 12.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool

    @State private var waterShift = false
    @State private var wave = false
    @State private var glow = false

    @State private var titleAppear = false
    @State private var subtitleAppear = false

    var body: some View {
        ZStack {

            // 💧 НЕЖНЫЙ ВОДЯНОЙ BACKGROUND (мягкий акварель)
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.55),
                    Color.purple.opacity(0.45),
                    Color.white.opacity(0.50)
                ],
                startPoint: waterShift ? .topLeading : .bottomTrailing,
                endPoint: waterShift ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .blur(radius: 28)
            .animation(
                .easeInOut(duration: 10).repeatForever(autoreverses: true),
                value: waterShift
            )

            // 💧 ТОЛҚЫН ЭФФЕКТІ (light water wave overlay)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.clear,
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 45)
                .rotationEffect(.degrees(wave ? 3 : -3))
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true),
                           value: wave)
                .ignoresSafeArea()

            VStack(spacing: 18) {

                Spacer()

                // 🌸 LOGO WITH WATER EFFECT
                Image("appLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)     
                    .shadow(color: .white.opacity(0.4), radius: 20)
                    .opacity(titleAppear ? 1 : 0)
                    .scaleEffect(titleAppear ? 1 : 0.7)
                    .rotationEffect(.degrees(wave ? 1.5 : -1.5))
                    .animation(.easeOut(duration: 1.0).delay(0.2), value: titleAppear)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true),
                               value: wave)


                Spacer()

                // ✨ CTA BUTTON — soft glow
                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showOnboarding = false
                    }
                } label: {
                    Text("Начать")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(24)
                        .shadow(color: .pink.opacity(0.4), radius: 15, y: 6)
                        .scaleEffect(glow ? 1.03 : 1)
                        .animation(
                            .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                            value: glow
                        )
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            // background water motion
            waterShift = true
            wave = true

            // text appearing
            titleAppear = true
            subtitleAppear = true

            // button pulse
            glow = true
        }
    }
}
