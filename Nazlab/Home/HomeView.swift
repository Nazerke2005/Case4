//
//  HomeView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//
import SwiftUI
import SwiftData

struct HomeView: View {

    @Query(
        sort: \LessonPlan.createdAt,
        order: .reverse
    )
    private var plans: [LessonPlan]

    @State private var searchText = ""
    @State private var selectedSubjects: Set<String> = []
    @State private var showFilters = false

    // Эти предметы тоже можно локализовать при желании
    private let subjects = [
        "Математика",
        "Қазақ тілі",
        "Русский язык",
        "Физика",
        "Информатика"
    ]

    // 🔍 Фильтрация
    private var filteredPlans: [LessonPlan] {
        plans.filter { plan in
            let matchesSearch =
                searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                plan.title.localizedCaseInsensitiveContains(searchText)

            let matchesSubject =
                selectedSubjects.isEmpty ||
                selectedSubjects.contains(plan.subject)

            return matchesSearch && matchesSubject
        }
    }

    // Пример плана для раздела "Образец поурочного плана"
    private var samplePlan: LessonPlan {
        LessonPlan(
            title: "Математика — 5 класс",
            subject: "Математика",
            grade: "5",
            objectives:
                """
                1) Повторить понятие дроби и её запись.
                2) Научиться складывать и вычитать дроби с одинаковыми знаменателями.
                3) Развивать навыки устного счёта и логического мышления.
                """,
            lessonFlow:
                """
                1) Организационный момент (2 мин)
                2) Актуализация знаний: короткая викторина по дробям (5 мин)
                3) Объяснение нового материала: сложение и вычитание дробей (15 мин)
                4) Практика в парах: 6–8 примеров (15 мин)
                5) Рефлексия: что было легко/сложно, вопросы (3 мин)
                """,
            assessment:
                """
                - Формативное оценивание по ходу выполнения заданий.
                - Мини-тест на 3–4 примера для самопроверки.
                """,
            homework:
                """
                - Решить 6 примеров на сложение и 6 примеров на вычитание дробей.
                - Подготовить 2 собственных примера и их решения.
                """,
            imageData: nil
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PinkPurpleFloatingBackground()

                ScrollView {
                    VStack(spacing: 24) {

                        // 🔤 Header (updated style)
                        VStack(spacing: 8) {
                            GradientTitle(NSLocalizedString("LessonPlanBuilderAI", comment: "Main title"))
                                .padding(.horizontal)

                            Text(NSLocalizedString("home.subtitle", comment: "Main subtitle"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 32)

                        // 🔍 Search + Filter
                        HStack(spacing: 12) {
                            TextField(NSLocalizedString("search.placeholder", comment: "Search placeholder"), text: $searchText)
                                .padding(14)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                            Button {
                                showFilters = true
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .accessibilityLabel(Text(NSLocalizedString("filters.title", comment: "Filters button")))
                            }
                        }
                        .padding(.horizontal)


                        VStack(alignment: .leading, spacing: 12) {
                            Text("Образец поурочного плана")
                                .font(.headline)
                                .padding(.horizontal)

                            NavigationLink {
                                LessonPlanPreviewView(plan: samplePlan)
                            } label: {
                                LessonPlanCardView(
                                    title: "Математика — 5 класс",
                                    subtitle: "Дроби. Сложение и вычитание",
                                    isSample: true
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }

                        // 📚 Saved plans
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("Ваши планы уроков", comment: "Saved plans header"))
                                .font(.headline)
                                .padding(.horizontal)

                            if filteredPlans.isEmpty {
                                Text(NSLocalizedString("Пока нет подходящих планов", comment: "Empty state"))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, minHeight: 120)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredPlans, id: \.id) { plan in
                                        NavigationLink {
                                            LessonPlanPreviewView(plan: plan)
                                        } label: {
                                            LessonPlanCardView(
                                                title: plan.title,
                                                subtitle: "\(plan.subject) • \(plan.createdAt.formatted(date: .numeric, time: .shortened))"
                                            )
                                        }
                                    }

                                }
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 30)
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheetView(
                    subjects: subjects,
                    selection: $selectedSubjects
                )
                .presentationDetents([.medium])
            }
        }
    }
}

private struct GradientTitle: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.system(size: 34, weight: .heavy, design: .rounded))
            .kerning(0.5)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.pink.opacity(0.95),
                        Color.purple.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .pink.opacity(0.15), radius: 10, y: 6)
            .shadow(color: .purple.opacity(0.10), radius: 14, y: 12)
            .multilineTextAlignment(.center)
    }
}
