//
//  main.swift
//  xliff2csv
//
//  Created by Norsez Orankijanan on 2/4/16.
//

import Foundation

func properOutputPath(outputPath: String, inputFilePath: String)  throws -> String {
  var result = NSString(string: inputFilePath).lastPathComponent
  let df = NSDateFormatter()
  df.dateFormat = "yyyyMMddhhmmss"
  let dstr = df.stringFromDate(NSDate())
  result = "\(result).\(dstr)"
  result = "\(outputPath)/\(result)"
  try NSFileManager.defaultManager().createDirectoryAtPath(result, withIntermediateDirectories: true, attributes: nil)
  return result
}

assert(Process.arguments.count==3, "xliff2csv <path to xliff file> <output path>")
let inputFilePath = Process.arguments[1]
print("input path: \(inputFilePath)")
let outputPath = Process.arguments[2]
print("output path: \(outputPath)")

let fm = NSFileManager.defaultManager()
var isDir: ObjCBool = false
let outputExisting = fm.fileExistsAtPath(outputPath, isDirectory: &isDir)

assert(isDir && outputExisting, "output path is invalid")

if let data = NSData(contentsOfFile: inputFilePath) {
  let parser = NSXMLParser(data: data)
  do {
    let folder = try properOutputPath(outputPath, inputFilePath: inputFilePath)
    let parserDelegate = Xliff2CsvParser(withFolderPath: folder )
    print("Output folder: \(folder)")
    parser.delegate = parserDelegate
    parser.parse()
  }catch {
    print (error)
  }
  
}else {
  print("\(inputFilePath) isn't a valid XLIFF file")
}


