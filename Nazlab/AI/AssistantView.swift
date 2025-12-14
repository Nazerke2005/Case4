//
//  AssistantView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 12.12.2025.
//

import SwiftUI
import SwiftData
import Combine

struct AssistantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var auth

    @StateObject private var viewModel = AssistantViewModel()

    var body: some View {
        ZStack {
            // 🎨 Фон
            PinkPurpleFloatingBackground()

            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {

                            // 💬 Сообщения
                            ForEach(viewModel.messages) { msg in
                                HStack(alignment: .bottom, spacing: 8) {

                                    if msg.role == .assistant {
                                        Text("🤖")
                                            .font(.title2)

                                        messageBubble(msg, isUser: false)
                                        Spacer()
                                    }

                                    if msg.role == .user {
                                        Spacer()
                                        messageBubble(msg, isUser: true)

                                        Text("👩")
                                            .font(.title2)
                                    }
                                }
                                .id(msg.id)
                            }

                            // ✍️ Typing indicator (AI пишет…)
                            if viewModel.isTyping {
                                HStack {
                                    Text("🤖")
                                        .font(.title2)

                                    TypingDotsView()
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))

                                    Spacer()
                                }
                                .padding(.horizontal)
                            }

                            // ❌ Ошибка
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // ✍️ Поле ввода
                HStack {
                    TextField("Задайте вопрос ИИ…", text: $viewModel.inputText)
                        .padding()
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 16)
                        )

                    Button {
                        Task { await viewModel.send() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .padding(12)
                            .background(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.isSending || viewModel.isTyping)
                }
                .padding()
            }
        }
        .navigationTitle("ИИ ассистент")
        .onAppear {
            if let email = auth.currentUserEmail {
                viewModel.configure(
                    service: GroqService(),
                    modelContext: modelContext,
                    currentUserEmail: email
                )
            }
        }
    }

    @ViewBuilder
    private func messageBubble(_ msg: Message, isUser: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(msg.text)
                .font(.body)
                .foregroundColor(isUser ? .white : .primary)

            Text(
                MessageTimeFormatter.shared.string(from: msg.timestamp)
            )
            .font(.caption2)
            .foregroundStyle(isUser ? .white.opacity(0.8) : .secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(
            isUser
            ? AnyShapeStyle(
                LinearGradient(
                    colors: [.pink, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
              )
            : AnyShapeStyle(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .frame(maxWidth: 260)
    }
}
