//
//  ContentView.swift
//  Nazlab
//
//  Created by Nazerke Turgанбек on 11.12.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var auth
    @Query private var items: [Item]

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            Group {
                if auth.isAuthenticated {
                    NavigationSplitView {
                        List {
                            ForEach(items) { item in
                                NavigationLink {
                                    Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                                } label: {
                                    Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                                }
                            }
                            .onDelete(perform: deleteItems)
                        }
#if os(macOS)
                        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
                        .toolbar {
#if os(iOS)
                            ToolbarItem(placement: .navigationBarTrailing) {
                                EditButton()
                            }
#endif
                            ToolbarItem {
                                Button(action: addItem) {
                                    Label("Add Item", systemImage: "plus")
                                }
                            }
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Выйти") {
                                    auth.signOut()
                                }
                            }
                        }
                    } detail: {
                        Text("Select an item")
                    }
                } else {
                    RegistrationView()
                }
            }
            .animation(.default, value: auth.isAuthenticated)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: User.self, Item.self)
    return ContentView()
        .environment(AuthManager())
        .modelContainer(container)
}
