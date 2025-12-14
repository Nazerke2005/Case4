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

    var body: some View {
        NavigationStack {
            ZStack {
                PinkPurpleFloatingBackground()

                ScrollView {
                    VStack(spacing: 24) {

                        // 🔤 Header
                        VStack(spacing: 8) {
                            Text("LessonPlanBuilderAI")
                            Text(NSLocalizedString("home.subtitle", comment: ""))
                        }
                        .padding(.top, 32)

                        // 🔍 Search + Filter
                        HStack(spacing: 12) {
                            TextField("Поиск по планам уроков", text: $searchText)
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
                            }
                        }
                        .padding(.horizontal)

                        // 📄 Sample
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Образец поурочного плана")
                                .font(.headline)
                                .padding(.horizontal)

                            LessonPlanCardView(
                                title: "Математика — 5 класс",
                                subtitle: "Дроби. Сложение и вычитание",
                                isSample: true
                            )
                        }

                        // 📚 Saved plans
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ваши планы уроков")
                                .font(.headline)
                                .padding(.horizontal)

                            if filteredPlans.isEmpty {
                                Text("Пока нет подходящих планов")
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
