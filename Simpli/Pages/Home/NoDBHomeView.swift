import SwiftUI
import CoreData

struct NoDBHomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showMessage: Bool = false
    @ObservedObject private var settings = Settings.shared
    @State private var feedbackMessage: LocalizedStringKey = "operation_finished"
    
    var body: some View {
        VStack {
            HStack {
                Text("welcome_message")
                Image(systemName: "face.smiling")
            }
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .padding(.top, 15)
            
            Text("manage_clients_message")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 100)
                

            Text("Please select workspace path to start.")
                .font(.title3)
                .foregroundColor(.secondary)
            Button(action: {
                initializeNewEnvironment(settings: Settings.shared)
                showMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation {
                        showMessage = false
                    }
                }
                
            }) {
                Text(LocalizedStringKey("create_workspace"))
                    .frame(minWidth:0 ,maxWidth: 300)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }
            .buttonStyle(PlainButtonStyle())

        }
        .frame(maxWidth: 500)
        .sheet(isPresented: $showMessage) {
            AutoDismissSheetView(
                message: feedbackMessage,
                displayDuration: 2,
                isPresented: $showMessage
            )
            .environment(\.locale, .init(identifier: settings.language.code))
        }
        .onChange(of: showMessage) {}
        Spacer()
    }
    
   

    private func handleFileSelection(message: String) {
        feedbackMessage = LocalizedStringKey(message)
        showMessage = true
    }

}
