//
//  PinkPurpleFloatingBackground.swift
//  Nazlab
//
//  Created by Nazerke Turganbек on 11.12.2025.
//

import SwiftUI

struct PinkPurpleFloatingBackground: View {
    @State private var animate = false
    @State private var t: CGFloat = 0 // параметр времени для плавающих смещений

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { _ in
            ZStack {
                
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.90, blue: 0.95), // нежно-розовый светлый
                        Color(red: 0.94, green: 0.86, blue: 0.98), // сиреневый светлый
                        Color(red: 0.98, green: 0.92, blue: 0.97)  // розово-лиловый
                    ],
                    startPoint: animate ? .topLeading : .bottomTrailing,
                    endPoint: animate ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()

                // Плавающие мягкие пятна (боке)
                ZStack {
                    floatingBlob(
                        color: Color.pink.opacity(0.25),
                        size: 280,
                        base: CGPoint(x: -60, y: -100),
                        amp: CGPoint(x: 60, y: 80),
                        speed: 0.18,
                        phase: 0.0
                    )

                    floatingBlob(
                        color: Color.purple.opacity(0.22),
                        size: 320,
                        base: CGPoint(x: 110, y: 160),
                        amp: CGPoint(x: 70, y: 90),
                        speed: 0.14,
                        phase: .pi / 3
                    )

                    floatingBlob(
                        color: Color.mint.opacity(0.12),
                        size: 260,
                        base: CGPoint(x: -10, y: 80),
                        amp: CGPoint(x: 50, y: 60),
                        speed: 0.22,
                        phase: .pi / 1.7
                    )

                    floatingBlob(
                        color: Color.white.opacity(0.10),
                        size: 360,
                        base: CGPoint(x: 20, y: 0),
                        amp: CGPoint(x: 40, y: 50),
                        speed: 0.12,
                        phase: .pi / 2.4
                    )
                }
                .blur(radius: 30)
                .blendMode(.softLight)
            }
            .onChange(of: animate) { _, _ in
                // no-op; держим для возможных реакций
            }
            .task {
                // Плавная бесконечная анимация градиента
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            .onAppear {
                // Обновляем параметр времени для плавающих смещений
                // TimelineView уже дергает body ~30fps, нам остается вычислять t
                t += 1/60
            }
        }
    }

    // Плавающий “блоб” с синусоидальными смещениями
    private func floatingBlob(
        color: Color,
        size: CGFloat,
        base: CGPoint,       // базовая позиция
        amp: CGPoint,        // амплитуда по x/y
        speed: CGFloat,      // скорость колебаний
        phase: CGFloat       // фазовый сдвиг
    ) -> some View {
        let time = t
        let x = base.x + sin(time * speed + phase) * amp.x
        let y = base.y + cos(time * speed + phase) * amp.y
        let scale = 1.02 + 0.04 * sin(time * (speed * 0.8) + phase / 2)

        return Circle()
            .fill(color)
            .frame(width: size, height: size)
            .offset(x: x, y: y)
            .scaleEffect(scale)
            .animation(.linear(duration: 0.0), value: time) // мгновенное обновление позиций по Timeline
    }
}
