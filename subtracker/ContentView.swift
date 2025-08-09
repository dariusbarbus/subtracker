//
//  ContentView.swift
//  subtracker
//
//  Created by Dario Simpson on 2025-07-04.
//

import SwiftUI

struct Subscription: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var amount: Double
    var date: Date
    var frequency: String

    init(id: UUID = UUID(), name: String, amount: Double, date: Date, frequency: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.frequency = frequency
    }
}

extension UserDefaults {
    private static let subscriptionsKey = "subscriptions"

    func saveSubscriptions(_ subscriptions: [Subscription]) {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            set(encoded, forKey: UserDefaults.subscriptionsKey)
        }
    }

    func loadSubscriptions() -> [Subscription] {
        if let data = data(forKey: UserDefaults.subscriptionsKey),
           let decoded = try? JSONDecoder().decode([Subscription].self, from: data) {
            return decoded
        }
        return []
    }
}

struct ContentView: View {
    // MARK: - State Variables

    // Controls whether the Add Subscription modal is shown
    @State private var showAddSubscription = false

    // Controls navigation to the MetricsView screen
    @State private var showMetrics = false

    // Holds the list of subscriptions with name, amount, date, and frequency
    @State private var subscriptions: [Subscription] = UserDefaults.standard.loadSubscriptions()

    // Tracks the subscription being edited
    @State private var editingSubscriptionIndex: Int? = nil

    // MARK: - Computed Properties

    // Calculates the total monthly cost, adjusting for frequency
    var totalMontlyAmount: Double {
        subscriptions.reduce(0) { total, sub in
            switch sub.frequency {
            case "Weekly":
                return total + (sub.amount * 4)
            case "Biweekly":
                return total + (sub.amount * 2)
            case "Monthly":
                return total + sub.amount
            default:
                return total // "Yearly" or unrecognized frequencies contribute nothing
            }
        }
    }

    // Calculates the total yearly cost including both monthly-based and yearly subscriptions
    var totalYearlyAmount: Double {
        subscriptions.reduce(0) { total, sub in
            switch sub.frequency {
            case "Weekly":
                return total + (sub.amount * 4 * 12)
            case "Biweekly":
                return total + (sub.amount * 2 * 12)
            case "Monthly":
                return total + (sub.amount * 12)
            case "Yearly":
                return total + sub.amount
            default:
                return total
            }
        }
    }

    // Calculates the next due date based on frequency
    func nextDueDate(from date: Date, frequency: String) -> Date {
        var components = DateComponents()
        switch frequency {
        case "Weekly":
            components.day = 7
        case "Biweekly":
            components.day = 14
        case "Monthly":
            components.month = 1
        case "Yearly":
            components.year = 1
        default:
            break
        }
        return Calendar.current.date(byAdding: components, to: date) ?? date
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Subscriptions")
                        .font(.largeTitle)
                        .bold()
                    Text("Active")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // MARK: - Subscription List or Empty Message
                if subscriptions.isEmpty {
                    // Display a placeholder message when there are no subscriptions
                    Text("No subscriptions yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Show a list of existing subscriptions
                    List {
                        ForEach(subscriptions.indices, id: \.self) { index in
                            let sub = subscriptions[index]
                            VStack(alignment: .leading) {
                                Text(sub.name)
                                    .font(.headline)

                                Text(String(format: "$%.2f", sub.amount))

                                Text("Due: \(sub.date.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .onTapGesture {
                                editingSubscriptionIndex = index
                            }
                        }
                        .onDelete { indices in
                            // Allows users to delete subscriptions from the list with animation
                            withAnimation {
                                subscriptions.remove(atOffsets: indices)
                            }
                        }
                    }
                }

                Spacer()

                // MARK: - Bottom Bar with Metrics, Count, and Add Button
                HStack {
                    // Button to navigate to the MetricsView
                    Button(action: {
                        showMetrics = true
                    }) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 26))
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Go to Metrics")
                    .padding(.horizontal)

                    Spacer()

                    // Display the number of subscriptions or a placeholder text
                    Text(
                        subscriptions.count == 0
                        ? "No subscriptions"
                        : "\(subscriptions.count) \(subscriptions.count == 1 ? "subscription" : "subscriptions")"
                    )
                    .font(.footnote)
                    .foregroundColor(.secondary)

                    Spacer()

                    // Button to open the Add Subscription modal
                    Button(action: {
                        showAddSubscription = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 26))
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Add Subscription")
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(Color(.systemGray6).ignoresSafeArea())

            // Navigate to MetricsView when showMetrics is true
            .navigationDestination(isPresented: $showMetrics) {
                MetricsView(
                    totalMontlyAmount: totalMontlyAmount,
                    totalYearlyAmount: totalYearlyAmount,
                    subscriptionsCount: subscriptions.count
                )
            }
        }

        // Show the modal view for adding or editing a subscription
        .sheet(isPresented: Binding<Bool>(
            get: { showAddSubscription || editingSubscriptionIndex != nil },
            set: {
                if !$0 {
                    showAddSubscription = false
                    editingSubscriptionIndex = nil
                }
            }
        )) {
            if let index = editingSubscriptionIndex {
                let sub = subscriptions[index]
                AddSubscriptionView(
                    initialName: sub.name,
                    initialAmount: String(sub.amount),
                    initialDate: sub.date,
                    initialFrequency: sub.frequency
                ) { name, amount, date, frequency in
                    subscriptions[index] = Subscription(id: sub.id, name: name, amount: amount, date: date, frequency: frequency)
                }
            } else {
                AddSubscriptionView { name, amount, date, frequency in
                    let dueDate = nextDueDate(from: date, frequency: frequency)
                    subscriptions.append(Subscription(name: name, amount: amount, date: dueDate, frequency: frequency))
                }
            }
        }
        .onChange(of: subscriptions) {
            UserDefaults.standard.saveSubscriptions(subscriptions)
        }
    }
}

#Preview {
    ContentView()
}
