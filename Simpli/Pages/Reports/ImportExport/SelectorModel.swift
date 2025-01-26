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
        panel.prompt = "Select Destination Folder"

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
        panel.prompt = "Select CSV File"
        
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
        panel.prompt = "Select JSON File"
        
        if panel.runModal() == .OK {
            return panel.url
        } else {
            return nil
        }
    }
}
