import SwiftUI

struct HelpView: View {
    var body: some View {
        CloseableHeader()
    
        VStack(alignment: .leading, spacing: 20) {
            Text("help_title")
                .font(.largeTitle)
                .padding(.bottom)
                .padding(.leading, 120)
            ScrollView {
                Text("overview_title")
                    .font(.title2)
                    .bold()
                Text("overview_description")

                Text("key_features_title")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 10) {
                    Text("feature_clients_management")
                    Text("feature_actions_management")
                    Text("feature_reports")
                    Text("feature_calendar")
                }

                Text("clients_title")
                    .font(.title2)
                    .bold()
                Text("clients_description")
                VStack(alignment: .leading, spacing: 5) {
                    Text("client_field_address")
                    Text("client_field_email")
                    Text("client_field_phone")
                    Text("client_field_name")
                    Text("client_field_gender")
                    Text("client_field_notes")
                    Text("client_field_custom")
                }

                Text("actions_title")
                    .font(.title2)
                    .bold()
                Text("actions_description")
                VStack(alignment: .leading, spacing: 5) {
                    Text("action_field_creation_date")
                    Text("action_field_criticality")
                    Text("action_field_due_date")
                    Text("action_field_id")
                    Text("action_field_message")
                    Text("action_field_status")
                    Text("action_field_type")
                }

                Text("reports_title")
                    .font(.title2)
                    .bold()
                Text("reports_description")

                Text("calendar_title")
                    .font(.title2)
                    .bold()
                Text("calendar_description")

                Text("getting_started_title")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 10) {
                    Text("getting_started_step_1")
                    Text("getting_started_step_2")
                    Text("getting_started_step_3")
                    Text("getting_started_step_4")
                    Text("getting_started_step_5")
                }

                Text("support_title")
                    .font(.title2)
                    .bold()
                Text("support_description")

                Spacer()
            }
            .padding()
        }
        .navigationTitle("help_nav_title")
    }
}
