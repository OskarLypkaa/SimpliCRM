import Foundation
import SwiftUI
import CoreData


func limitText(_ text: inout String, to maxCharacters: Int) {
      if text.count > maxCharacters {
          text = String(text.prefix(maxCharacters))
      }
  }
