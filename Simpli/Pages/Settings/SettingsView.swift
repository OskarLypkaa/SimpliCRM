import SwiftUI

// Struktura Settings
struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext  // Link do bazy danych

    @AppStorage("appColor") private var appColor: String = "Blue" // Kolor aplikacji (zapisany w UserDefaults)
    @AppStorage("language") private var language: String = "en" // Język (zapisany w UserDefaults)

    let languageOptions = ["en": "English", "pl": "Polski", "de": "Deutsch", "it": "Italiano", "fr": "Français"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Database")) {
                    Text("Database Link:")
                        .font(.headline)
                    Text("\(viewContext)") // Wyświetlanie linku do bazy danych (tutaj tylko placeholder)
                        .font(.subheadline)
                }

                Section(header: Text("Appearance")) {
                    Picker("App Color", selection: $appColor) {
                        Text("Blue").tag("Blue")
                        Text("Green").tag("Green")
                        Text("Red").tag("Red")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Language")) {
                    Picker("Select Language", selection: $language) {
                        ForEach(languageOptions.keys.sorted(), id: \.self) { key in
                            Text(languageOptions[key] ?? "").tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: language) { newLanguage in
            setLanguage(to: newLanguage)
        }
    }

    private func setLanguage(to languageCode: String) {
        // Tutaj możesz zaimplementować zmianę języka w aplikacji
        // Na przykład, zmiana lokalizacji przy użyciu `Locale` w SwiftUI
        print("Language changed to: \(languageCode)")
    }
}

#Preview {
    SettingsView()
}
