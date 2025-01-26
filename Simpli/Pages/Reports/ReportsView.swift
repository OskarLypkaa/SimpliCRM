import SwiftUI

struct ReportView: View {
    @State private var showStatisticView = false // Stan kontrolujący widoczność arkusza
    
    @State private var showSuccessMessage: Bool = false
    @State private var succesMessage: LocalizedStringKey = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)], animation: .default)
    private var clients: FetchedResults<Client>
    
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
                            title: LocalizedStringKey("customer_analytics_title"),
                            subtitle: LocalizedStringKey("customer_analytics_subtitle"),
                            image: "person.2.fill",
                            isUnderDevelopment: true,
                            action: {
                                print("Customer Analytics")
                                // Wywołanie funkcji do analizy klientów
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("monthly_revenue_report_title"),
                            subtitle: LocalizedStringKey("monthly_revenue_report_subtitle"),
                            image: "calendar",
                            isUnderDevelopment: true,
                            action: {
                                print("Generate Monthly Revenue Report")
                                // Wywołanie funkcji generowania raportu miesięcznego przychodu
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("weekly_revenue_report_title"),
                            subtitle: LocalizedStringKey("weekly_revenue_report_subtitle"),
                            image: "calendar",
                            isUnderDevelopment: true,
                            action: {
                                print("Generate Monthly Revenue Report")
                                // Wywołanie funkcji generowania raportu miesięcznego przychodu
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("task_completion_overview_title"),
                            subtitle: LocalizedStringKey("task_completion_overview_subtitle"),
                            image: "checkmark.circle.fill",
                            isUnderDevelopment: true,
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
                            isUnderDevelopment: true,
                            action: {
                                

                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("export_to_pdf_title"),
                            subtitle: LocalizedStringKey("export_to_pdf_subtitle"),
                            image: "doc.richtext.fill",
                            isUnderDevelopment: true,
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
                                exportWithLoading(exportType: "csv", data: clients, fileName: "Clients", filePath: Selector.shared.setDestinationFolder()!) {
                                    succesMessage = LocalizedStringKey("Clients exported succesfully")
                                    showSuccessMessage = true
                                }
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("export_to_json_title"),
                            subtitle: LocalizedStringKey("export_to_json_subtitle"),
                            image: "curlybraces.square.fill",
                            isUnderDevelopment: false,
                            action: {
                                exportWithLoading(exportType: "json", data: clients, fileName: "Clients", filePath: Selector.shared.setDestinationFolder()!) {
                                    succesMessage = LocalizedStringKey("Clients exported succesfully")
                                    showSuccessMessage = true
                                }
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
                            isUnderDevelopment: true,
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
                                importWithLoading(context: viewContext, importType: "csv", filePath: Selector.shared.selectCSVFile()!) {
                                    succesMessage = LocalizedStringKey("Clients imported succesfully")
                                    showSuccessMessage = true
                                }
                            }
                        )
                        ActionButton(
                            title: LocalizedStringKey("import_from_json_title"),
                            subtitle: LocalizedStringKey("import_from_json_subtitle"),
                            image: "arrow.down.circle.fill",
                            isUnderDevelopment: false,
                            action: {
                                importWithLoading(context: viewContext, importType: "json", filePath: Selector.shared.selectJSONFile()!) {
                                    succesMessage = LocalizedStringKey("Clients imported succesfully")
                                    showSuccessMessage = true
                                }
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
        .sheet(isPresented: $showSuccessMessage) {
            AutoDismissSheetView(
                message: succesMessage,
                displayDuration: 1.5,
                isPresented: $showSuccessMessage
            )
        }
    }
}
