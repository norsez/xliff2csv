//
//  Csv2XliffParser.swift
//  xliff2csv
//
//  Created by Norsez Orankijanan on 3/10/16.
//  Copyright © 2016 Startsiden. All rights reserved.
//

import Foundation

class Csv2XliffParser {
  
  let XML_HEADER_TEXT  = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<xliff xmlns=\"urn:oasis:names:tc:xliff:document:1.2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" version=\"1.2\" xsi:schemaLocation=\"urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd\">\n  <file original=\"%@\" source-language=\"en\" datatype=\"plaintext\" target-language=\"%lang\">\n<header>\n<tool tool-id=\"com.apple.dt.xcode\" tool-name=\"Xcode\" tool-version=\"7.2.1\" build-num=\"7C1002\"/>\n</header>\n  <body>"
  
  enum Column: Int {
    case TransUnit, Note, Source, Target
  }
  
  var csvFileURL: NSURL
  var outputPathURL: NSURL
  var lines =  [String]()
  init(withFileURL url: NSURL, outputPath: NSURL) {
    self.csvFileURL = url
    self.outputPathURL = outputPath
  }
  
  private func lineToXML(withColumns cols: [String]) -> String {
    var text = ""
    
    if (cols.count > 1) {
      let note = cols[1]
      text = "<note>\(note)</note>"
    }
    
    if (cols.count > 2) {
      let src = cols[2]
      text = "\(text)\n<source>\(src)</source>"
    }
    
    if (cols.count > 3) {
      let tar = cols[3]
      text = "\(text)\n<source>\(tar)</source>"
    }
    
    if (cols.count > 0){
      let id = cols[0]
      text = "<trans-unit id=\"\(id)\">\(text)</trans-unit>"
    }
    
    return "\(text)\n"
  }
  
  func parse () {
    if let data = NSData(contentsOfURL: self.csvFileURL),
      let csvContent = String(data: data, encoding: NSUTF8StringEncoding) {
        
        self.lines = csvContent.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:"\n"))
        
        if let originalFileName = self.csvFileURL.lastPathComponent {
          var filename = originalFileName.stringByReplacingOccurrencesOfString(".csv", withString: "")
          
          let comps = filename.componentsSeparatedByString(".")
          var lang = ""
          if let l = comps.last {
            lang = l
            filename = filename.stringByReplacingOccurrencesOfString(".\(l)", withString: "")
          }
          
          var outputContent = XML_HEADER_TEXT.stringByReplacingOccurrencesOfString("%@", withString: filename)
          
          outputContent = outputContent.stringByReplacingOccurrencesOfString("%lang", withString: lang)
          
          self.lines.forEach({ (line) -> () in
            var columns = line.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
            columns = columns.flatMap({ (str) -> String? in
              let p = str.stringByReplacingOccurrencesOfString("\"\"", withString: "\"")
              return p
            })
            
            outputContent = "\(outputContent) \(self.lineToXML(withColumns: columns))"
          })
          
          outputContent = "\(outputContent)</body>\n</file>"
          
          var outputURL = self.outputPathURL
          outputURL = outputURL.URLByAppendingPathComponent(lang)
          outputURL = outputURL.URLByAppendingPathExtension("xliff")
          
          if let outData = outputContent.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
              try outData.writeToURL(outputURL, options: .AtomicWrite)
              print("saved \(outputURL)")
            }catch {
              print(error)
            }
          }
        }
    }
  }
}
