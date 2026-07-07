import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: CycleEntry?

    var body: some View {
        NavigationStack {
            Group {
                if store.entries.isEmpty {
                    ContentUnavailableView("No entries yet", systemImage: "pawprint.fill", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button {
                                editingEntry = entry
                            } label: {
                                HStack {
                                    Text(entry.startDate, style: .date)
                                        .font(Theme.headlineFont)
                                    Spacer()
                                    Text(entry.endDate ?? Date(), style: .date)
                                        .foregroundStyle(Theme.accent)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Heatcycle")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add)
                    .environmentObject(store)
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(mode: .edit(entry))
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(purchases)
            }
        }
    }
}

enum FormMode: Equatable {
    case add
    case edit(CycleEntry)
}

struct EntryFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let mode: FormMode

    @State private var draftStartDate: Date = Date()
    @State private var draftEndDate: Date? = nil
    @State private var draftNotes: String = ""

    init(mode: FormMode) {
        self.mode = mode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    DatePicker("Startdate", selection: $draftStartDate, displayedComponents: .date)
                    DatePicker("Enddate", selection: Binding(get: { draftEndDate ?? Date() }, set: { draftEndDate = $0 }), displayedComponents: .date)
                    TextField("Notes", text: $draftNotes)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func populateIfEditing() {
        if case .edit(let entry) = mode {
            draftStartDate = entry.startDate
            draftEndDate = entry.endDate
            draftNotes = entry.notes
        }
    }

    private func save() {
        switch mode {
        case .add:
            let entry = CycleEntry(startDate: draftStartDate, endDate: draftEndDate, notes: draftNotes)
            store.add(entry)
        case .edit(var entry):
            entry.startDate = draftStartDate
            entry.endDate = draftEndDate
            entry.notes = draftNotes
            store.update(entry)
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
