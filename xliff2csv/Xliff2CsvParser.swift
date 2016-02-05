//
//  Xliff2CsvParser.swift
//  xliff2csv
//
//  Created by Norsez Orankijanan on 2/4/16.
//

import Foundation

extension String {
  mutating func addCsvCell(str: String) {
    let txt = str.stringByReplacingOccurrencesOfString("\"", withString: "\"\"")
    self.appendContentsOf(",\"\(txt)\"")
  }
  mutating func addBlankCsvCell() {
    self.appendContentsOf(",\"\"")
  }
}

class Xliff2CsvParser:NSObject, NSXMLParserDelegate {
  
  struct Field {
    static let file = "file"
    static let original = "original"
    static let body = "body"
    static let trans_unit = "trans-unit"
    static let trans_unit_id = "trans-unit-id"
    static let source = "source"
    static let target = "target"
    static let note = "note"
  }
  
  var rows = [[String:String]]()
  var currentField: String?
  var currentTranslationUnit: [String:String]?
  var currentFilename: String?
  var chars = ""
  let folderPath: String
  
  init(withFolderPath folderPath: String) {
    self.folderPath = folderPath
    let fm = NSFileManager.defaultManager()
    var isDir: ObjCBool = false
    let existing = fm.fileExistsAtPath(folderPath, isDirectory:&isDir)
    assert(existing == true && isDir , "\(folderPath) isn't a path")
    
    super.init()
  }
  
  func parserDidStartDocument(parser: NSXMLParser) {
    print("start parsing…")
  }
  
  private func _startNewFile(withName name:String){
    self.rows = [[String:String]]()
    self.currentFilename = name
  }
  
  private func _saveFile() {
    var strToSave = ""
    strToSave.addCsvCell("Translation Unit Id")
    strToSave.addCsvCell("Engineer's Comments")
    strToSave.addCsvCell("Source")
    strToSave.addCsvCell("Target")
    strToSave.appendContentsOf("\n")
    
    for r in rows {
      
      if let s = r[Field.trans_unit_id] {
        strToSave.addCsvCell(s)
      }else {
        strToSave.addBlankCsvCell()
      }
      
      if let s = r[Field.note] {
        strToSave.addCsvCell(s)
      }else {
        strToSave.addBlankCsvCell()
      }
      
      if let s = r[Field.source] {
        strToSave.addCsvCell(s)
      }else {
        strToSave.addBlankCsvCell()
      }

      if let s = r[Field.target] {
        strToSave.addCsvCell(s)
      }else {
        strToSave.addBlankCsvCell()
      }
      
      strToSave.appendContentsOf("\n")
    }
    
    if let data = strToSave.dataUsingEncoding(NSUTF8StringEncoding) {
      if let filename = self.currentFilename?.stringByReplacingOccurrencesOfString("/", withString: "_"){
        let pathToSave = "\(self.folderPath)/\(filename).csv"
        do {
          try data.writeToFile(pathToSave, options: .DataWritingAtomic)
          print ("saved \(pathToSave).")
        }catch {
          print(error)
          exit(-1)
        }
      }else {
        assert(self.currentFilename != nil, "current file name is nil")
      }
      
    }
  }
  
  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    
    self.currentField = elementName
    switch elementName {
    case Field.file:
      if let fileName = attributeDict["original"]{
        self._startNewFile(withName: fileName)
      }
      break
    case Field.trans_unit:
      self.currentTranslationUnit = [String:String]()
      self.currentTranslationUnit?[Field.trans_unit_id] = attributeDict["id"]
    default:
      chars = ""
      print("start element \(elementName)")
    }
    
  }
  
  func parser(parser: NSXMLParser, foundCharacters string: String) {
    chars = "\(chars)\(string)"
  }
  
  func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case Field.trans_unit:
      if let transUnit = self.currentTranslationUnit {
        rows.append(transUnit)
      }
      break
    case Field.source:
      self.currentTranslationUnit?[Field.source] = self.chars
      break
    case Field.target:
      self.currentTranslationUnit?[Field.target] = self.chars
      break
    case Field.note:
      self.currentTranslationUnit?[Field.note] = self.chars
      break
    case Field.file:
      self._saveFile()
    default:
      self.chars = ""
    }
  }
  
  func parserDidEndDocument(parser: NSXMLParser) {
    print("end parsing")
  }
}
