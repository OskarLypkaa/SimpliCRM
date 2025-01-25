import SwiftUI

struct ReportView: View {
    @State private var showDataView = false // Stan kontrolujący widoczność arkusza

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
                        ActionButton(title: LocalizedStringKey("generate_sales_report_title"), subtitle: LocalizedStringKey("generate_sales_report_subtitle"), image: "chart.bar.fill")
                        ActionButton(title: LocalizedStringKey("customer_analytics_title"), subtitle: LocalizedStringKey("customer_analytics_subtitle"), image: "person.2.fill")
                        ActionButton(title: LocalizedStringKey("monthly_revenue_report_title"), subtitle: LocalizedStringKey("monthly_revenue_report_subtitle"), image: "calendar")
                        ActionButton(title: LocalizedStringKey("task_completion_overview_title"), subtitle: LocalizedStringKey("task_completion_overview_subtitle"), image: "checkmark.circle.fill")

                        // ActionButton wywołujący DataView
                        ActionButton(title: LocalizedStringKey("statistic_overview_title"), subtitle: LocalizedStringKey("statistic_overview_subtitle"), image: "chart.line.uptrend.xyaxis.circle.fill")
                            .onTapGesture {
                                showDataView = true // Pokazuje arkusz po kliknięciu
                            }
                            .sheet(isPresented: $showDataView) {
                                DataView() // Wywołanie istniejącego DataView
                            }
                    }
                }
                .padding(.horizontal)

                // Sekcja eksportu danych
                VStack(alignment: .leading, spacing: 20) {
                    Text(LocalizedStringKey("data_export_section"))
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(spacing: 15) {
                        ActionButton(title: LocalizedStringKey("export_to_excel_title"), subtitle: LocalizedStringKey("export_to_excel_subtitle"), image: "doc.fill")
                        ActionButton(title: LocalizedStringKey("export_to_pdf_title"), subtitle: LocalizedStringKey("export_to_pdf_subtitle"), image: "doc.richtext.fill")
                        ActionButton(title: LocalizedStringKey("export_to_csv_title"), subtitle: LocalizedStringKey("export_to_csv_subtitle"), image: "tablecells.fill")
                        ActionButton(title: LocalizedStringKey("export_to_json_title"), subtitle: LocalizedStringKey("export_to_json_subtitle"), image: "curlybraces.square.fill")
                    }
                }
                .padding(.horizontal)

                // Sekcja importu danych
                VStack(alignment: .leading, spacing: 20) {
                    Text(LocalizedStringKey("data_import_section"))
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(spacing: 15) {
                        ActionButton(title: LocalizedStringKey("import_from_excel_title"), subtitle: LocalizedStringKey("import_from_excel_subtitle"), image: "square.and.arrow.down.fill")
                        ActionButton(title: LocalizedStringKey("import_from_csv_title"), subtitle: LocalizedStringKey("import_from_csv_subtitle"), image: "arrow.down.circle.fill")
                        ActionButton(title: LocalizedStringKey("import_from_json_title"), subtitle: LocalizedStringKey("import_from_json_subtitle"), image: "arrow.down.circle.fill")
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom, 20)
        }
    }
}

// Podgląd dla widoku
struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
