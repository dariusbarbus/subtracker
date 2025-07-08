//
//  MetricsView.swift
//  subtracker
//
//  Created by Dario Simpson on 2025-07-04.
//

import SwiftUI

/// A view that displays key subscription metrics such as the total monthly cost and the number of subscriptions.
/// It receives the total monthly amount as input and uses environment dismissal to allow programmatic closing if needed.
struct MetricsView: View {
    // MARK: - Input

    // Total value of all subscriptions passed from parent view
    var totalMontlyAmount: Double
    var totalYearlyAmount: Double
    var subscriptionsCount: Int

    // Used to programmatically dismiss the view (e.g., if needed)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // MARK: - Metric Cards
            VStack(spacing: 16) {
                // Number of Subscriptions Card
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        VStack {
                            Text("Number of Subscriptions")
                                .font(.subheadline)
                                .foregroundColor(.green)

                            Text("\(subscriptionsCount)")
                                .font(.title)
                                .bold()
                        }
                    )

                // Total Monthly Cost Card
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        VStack {
                            Text("Total Monthly Cost")
                                .font(.subheadline)
                                .foregroundColor(.blue)

                            Text(String(format: "$%.2f", totalMontlyAmount))
                                .font(.title)
                                .bold()
                        }
                    )

                // Total Yearly Cost Card
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        VStack {
                            Text("Total Yearly Cost")
                                .font(.subheadline)
                                .foregroundColor(.purple)

                            Text(String(format: "$%.2f", totalYearlyAmount))
                                .font(.title)
                                .bold()
                        }
                    )
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Metrics")
    }
}
