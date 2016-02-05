//
//  main.swift
//  xliff2csv
//
//  Created by Norsez Orankijanan on 2/4/16.
//  Copyright © 2016 Startsiden. All rights reserved.
//

import Foundation

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
  let parserDelegate = Xliff2CsvParser(withFolderPath: outputPath)
  parser.delegate = parserDelegate
  parser.parse()
  
}else {
  print("\(inputFilePath) isn't a valid XLIFF file")
}







