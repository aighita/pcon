// macOS: swift -disable-sandbox -module-cache-path /tmp/pcsv-swift-cache tools/exporta_png.swift
import Foundation
import PDFKit
import AppKit
let root=URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent()
let dir=root.appendingPathComponent("rezultate/referinta_python")
let urls=(FileManager.default.enumerator(at:dir,includingPropertiesForKeys:nil)!.allObjects as! [URL]).filter{$0.pathExtension=="pdf"}
for url in urls {
    let pdf=PDFDocument(url:url)!
    let im=pdf.page(at:0)!.thumbnail(of:NSSize(width:2000,height:3000),for:.mediaBox)
    let rep=NSBitmapImageRep(data:im.tiffRepresentation!)!
    try! rep.representation(using:.png,properties:[:])!.write(to:url.deletingPathExtension().appendingPathExtension("png"))
}
print("\(urls.count) figuri PDF exportate PNG.")
