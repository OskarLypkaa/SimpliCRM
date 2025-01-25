import SwiftUI

class Settings: ObservableObject {
    // Singleton dla globalnego dostępu
    static let shared = Settings()

    // Ścieżka do bazy danych i plików
    @Published var sharedPath: String

    // Tryb jasny/ciemny
    @Published var themeMode: ThemeMode

    // Styl animacji
    @Published var animationStyle: AnimationStyle

    // Wybrany język
    @Published var language: Language

    // Prywatny inicjalizator
    private init(
        sharedPath: String = "",
        themeMode: ThemeMode = .system,
        animationStyle: AnimationStyle = .minimalistic,
        language: Language = .english
    ) {
        self.sharedPath = sharedPath
        self.themeMode = themeMode
        self.animationStyle = animationStyle
        self.language = language
    }
}


// Enum dla trybu jasny/ciemny
enum ThemeMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

enum AnimationStyle: String, CaseIterable {
    case none = "None"
    case minimalistic = "Minimalistic"
    case maximum = "Maximum"
}

// Enum dla języków
enum Language: String, CaseIterable {
    case english = "English"
    case german = "Deutsch"
    case polish = "Polski"
}

struct SettingsView: View {
    // Odwołanie do singletona
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        Text("App Settings")
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.top, 20)

        Text("Adjust general app preferences, including report generation, data visualization, and export/import options.")
            .font(.title3)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.bottom, 30)

        ScrollView {
            Form {
                Section(header: Text("Paths").font(.headline)) {
                    VStack {
                        Text("Storage File Path:")
                        TextField("", text: $settings.sharedPath)
                            .padding(.bottom, 10)
                        Text("Files Path:")
                        TextField("", text: $settings.sharedPath)
                            .padding(.bottom, 10)
                    }
                    
                }
                Spacer()
                Section(header: Text("Appearance").font(.headline)) {
                    VStack {
                        Picker("", selection: $settings.themeMode) {
                            ForEach(ThemeMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom, 10)
                    }
                }
                Spacer()
                Section(header: Text("Language").font(.headline)) {
                    Picker("", selection: $settings.language) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                }
                Spacer()
            }
        }
        .frame(width: 500, alignment: .leading)
    }
}

#Preview {
    SettingsView()
}
