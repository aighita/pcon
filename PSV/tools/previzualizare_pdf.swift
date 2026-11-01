// Rulare pe macOS: swift -disable-sandbox -module-cache-path /tmp/pcsv-swift-cache tools/previzualizare_pdf.swift
import Foundation
import PDFKit
import AppKit
let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let pdf = PDFDocument(url: root.appendingPathComponent("laborator.pdf"))!
let out = root.appendingPathComponent("documentatie/figuri")
for (name, size) in [("preview.jpg", NSSize(width: 1200,height: 1698)), ("preview-web.jpg", NSSize(width: 500,height: 707)), ("preview-micro.jpg", NSSize(width: 64,height: 91))] {
    let thumb = pdf.page(at:0)!.thumbnail(of:size,for:.mediaBox)
    let rep = NSBitmapImageRep(data:thumb.tiffRepresentation!)!
    try! rep.representation(using:.jpeg,properties:[.compressionFactor:0.85])!.write(to:out.appendingPathComponent(name))
}
print("PDF: \(pdf.pageCount) pagini. Previzualizari actualizate.")
