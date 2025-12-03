import SwiftUI

struct DateSelectorView: View {
    @Binding var selectedDate: Date
    @State private var showCalendar = false

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        HStack(spacing: 8) {
            // Left arrow
            Button {
                changeDate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
            }

            // Center pill with date
            Button {
                showCalendar = true
            } label: {
                SelectedDateOverlay(date: selectedDate, isToday: Calendar.current.isDateInToday(selectedDate))
                    .frame(width: 120, height: 36)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
            }

            // Right arrow
            Button {
                changeDate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
            }
        }
        .frame(height: 44)
        .sheet(isPresented: $showCalendar) {
            CalendarPickerView(selectedDate: $selectedDate)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Helper Methods

    private func changeDate(by days: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) else { return }

        HapticManager.shared.light()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedDate = newDate
        }
    }
}

// MARK: - Selected Date Overlay

struct SelectedDateOverlay: View {
    let date: Date
    let isToday: Bool

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM"
        return formatter.string(from: date)
    }

    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    private var ordinalSuffix: String {
        let ones = dayNumber % 10
        let tens = (dayNumber / 10) % 10

        if tens == 1 {
            return "th"
        }

        switch ones {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }

    var body: some View {
        if isToday {
            Text("Today")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        } else {
            HStack(spacing: 2) {
                Text(formattedDate)
                    .font(.system(size: 13, weight: .medium, design: .rounded))

                Text(" ")

                Text("\(dayNumber)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))

                Text(ordinalSuffix)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .offset(y: -1)
            }
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Calendar Picker

struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.blue)
                .onChange(of: selectedDate) { _, _ in
                    HapticManager.shared.light()
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    DateSelectorView(selectedDate: .constant(Date()))
        .padding()
}
