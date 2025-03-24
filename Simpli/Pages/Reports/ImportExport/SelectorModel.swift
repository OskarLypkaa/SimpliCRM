import SwiftUI
import UniformTypeIdentifiers

class Selector {
    static let shared = Selector()
    
    private init() {}
    
    func setDestinationFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = NSLocalizedString("select_destination_folder", comment: "")
        
        if panel.runModal() == .OK {
            return panel.url
        } else {
            return nil
        }
    }
    
    func selectCSVFile() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "csv")!]
        panel.prompt = NSLocalizedString("select_csv_file", comment: "")
        
        if panel.runModal() == .OK {
            return panel.url
        } else {
            return nil
        }
    }

    func selectJSONFile() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "json")!]
        panel.prompt = NSLocalizedString("select_json_file", comment: "")
        
        if panel.runModal() == .OK {
            return panel.url
        } else {
            return nil
        }
    }
}
