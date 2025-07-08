//
//  AddSubscriptionView.swift
//  subtracker
//
//  Created by Dario Simpson on 2025-07-04.
//
//  This view allows the user to input a new subscription by specifying its
//  name, cost, billing date, and renewal frequency. It uses a form with text fields, a date picker, and a picker,
//  and returns the result using the provided onSave callback.

import SwiftUI

struct AddSubscriptionView: View {
    var initialName: String = ""
    var initialAmount: String = ""
    var initialDate: Date = Date()
    var initialFrequency: String = "Monthly"

    // MARK: - Environment
    @Environment(\.dismiss) var dismiss

    // MARK: - Form State Variables
    @State private var name: String
    @State private var amount: String
    @State private var date: Date
    @State private var frequency: String

    // Callback to pass the new subscription data back to the parent view
    var onSave: (String, Double, Date, String) -> Void

    init(
        initialName: String = "",
        initialAmount: String = "",
        initialDate: Date = Date(),
        initialFrequency: String = "Monthly",
        onSave: @escaping (String, Double, Date, String) -> Void
    ) {
        self._name = State(initialValue: initialName)
        self._amount = State(initialValue: initialAmount)
        self._date = State(initialValue: initialDate)
        self._frequency = State(initialValue: initialFrequency)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Subscription Name Input
                TextField("Service Name", text: $name)

                // MARK: - Subscription Amount Input
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)

                // MARK: - Subscription Date Input
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: .date
                )
                
                // MARK: - Subscription Frequency Picker
                Picker("Renewal Frequency", selection: $frequency) {
                    Text("Weekly").tag("Weekly")
                    Text("Biweekly").tag("Biweekly")
                    Text("Monthly").tag("Monthly")
                    Text("Yearly").tag("Yearly")
                }
                .pickerStyle(.menu)
            }
            .navigationTitle("New Subscription")
            .toolbar {
                // MARK: - Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Try to convert amount string to Double before saving
                        if let amountValue = Double(amount) {
                            onSave(name, amountValue, date, frequency)
                            dismiss()
                        }
                    }
                }

                // MARK: - Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
