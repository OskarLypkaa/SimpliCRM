import SwiftUI

struct ReportView: View {
    @State private var showStatisticView = false // Stan kontrolujący widoczność arkusza

    var body: some View {
        VStack(spacing: 30) {
            // Nagłówek
            Text(LocalizedStringKey("reports_title"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Text(LocalizedStringKey("reports_subtitle"))
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            ScrollView {
                // Sekcja raportów
                VStack(alignment: .leading, spacing: 20) {
                    Text(LocalizedStringKey("reports_generate_section"))
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(spacing: 15) {
                        ActionButton(
                            title: LocalizedStringKey("generate_sales_report_title"),
                            subtitle: LocalizedStringKey("generate_sales_report_subtitle"),
                            image: "chart.bar.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Generate Sales Report")
                                // Wywołanie funkcji generowania raportu sprzedaży
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("customer_analytics_title"),
                            subtitle: LocalizedStringKey("customer_analytics_subtitle"),
                            image: "person.2.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Customer Analytics")
                                // Wywołanie funkcji do analizy klientów
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("monthly_revenue_report_title"),
                            subtitle: LocalizedStringKey("monthly_revenue_report_subtitle"),
                            image: "calendar",
                            isUnderDevelopment: false,
                            action: {
                                print("Generate Monthly Revenue Report")
                                // Wywołanie funkcji generowania raportu miesięcznego przychodu
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("task_completion_overview_title"),
                            subtitle: LocalizedStringKey("task_completion_overview_subtitle"),
                            image: "checkmark.circle.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Task Completion Overview")
                                // Wywołanie funkcji przeglądu ukończonych zadań
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("statistic_overview_title"),
                            subtitle: LocalizedStringKey("statistic_overview_subtitle"),
                            image: "chart.line.uptrend.xyaxis.circle.fill",
                            isUnderDevelopment: false,
                            action: {
                                showStatisticView = true // Otwieranie arkusza statystyk
                            }
                        )
                    }
                }
                .padding(.horizontal)

                // Sekcja eksportu danych
                VStack(alignment: .leading, spacing: 20) {
                    Text(LocalizedStringKey("data_export_section"))
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(spacing: 15) {
                        ActionButton(
                            title: LocalizedStringKey("export_to_excel_title"),
                            subtitle: LocalizedStringKey("export_to_excel_subtitle"),
                            image: "doc.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Export to Excel")
                                // Wywołanie funkcji eksportu do Excel
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("export_to_pdf_title"),
                            subtitle: LocalizedStringKey("export_to_pdf_subtitle"),
                            image: "doc.richtext.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Export to PDF")
                                // Wywołanie funkcji eksportu do PDF
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("export_to_csv_title"),
                            subtitle: LocalizedStringKey("export_to_csv_subtitle"),
                            image: "tablecells.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Export to CSV")
                                // Wywołanie funkcji eksportu do CSV
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("export_to_json_title"),
                            subtitle: LocalizedStringKey("export_to_json_subtitle"),
                            image: "curlybraces.square.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Export to JSON")
                                // Wywołanie funkcji eksportu do JSON
                            }
                        )
                    }
                }
                .padding(.horizontal)

                // Sekcja importu danych
                VStack(alignment: .leading, spacing: 20) {
                    Text(LocalizedStringKey("data_import_section"))
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(spacing: 15) {
                        ActionButton(
                            title: LocalizedStringKey("import_from_excel_title"),
                            subtitle: LocalizedStringKey("import_from_excel_subtitle"),
                            image: "square.and.arrow.down.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Import from Excel")
                                // Wywołanie funkcji importu z Excel
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("import_from_csv_title"),
                            subtitle: LocalizedStringKey("import_from_csv_subtitle"),
                            image: "arrow.down.circle.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Import from CSV")
                                // Wywołanie funkcji importu z CSV
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("import_from_json_title"),
                            subtitle: LocalizedStringKey("import_from_json_subtitle"),
                            image: "arrow.down.circle.fill",
                            isUnderDevelopment: false,
                            action: {
                                print("Import from JSON")
                                // Wywołanie funkcji importu z JSON
                            }
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showStatisticView) {
            StatisticView() // Prezentowanie arkusza z widokiem statystyk
        }
    }
}
