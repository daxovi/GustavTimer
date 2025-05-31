//
//  IntervalEditView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//

import SwiftUI

struct IntervalEditView: View {
    @Binding var interval: IntervalModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Název") {
                    TextField("Název intervalu", text: $interval.name)
                }

                Section("Délka") {
                    Stepper("\(interval.duration) s", value: $interval.duration, in: 1...600)
                }

                Section("Typ") {
                    Picker("Typ", selection: $interval.type) {
                        ForEach(IntervalType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Barva") {
                    ColorPicker("Vyber barvu", selection: Binding(
                        get: { interval.color },
                        set: { interval.color = $0 }
                    ))
                }
            }
            .navigationTitle("Upravit interval")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hotovo") { dismiss() }
                }
            }
        }
    }
}
