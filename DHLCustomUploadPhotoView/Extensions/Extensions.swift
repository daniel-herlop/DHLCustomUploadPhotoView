//
//  Extensions.swift
//  DHLCustomUploadPhotoView
//
//  Created by Daniel Hernandez on 11/06/2026.
//

import Foundation
import UIKit
import WebKit
import PDFKit

extension Data {
    
    func detectFileType() -> String? {
        // PDF signature: "%PDF"
        if self.starts(with: [0x25, 0x50, 0x44, 0x46]) {
            return "PDF"
        }
        
        // JPEG signature: FF D8 FF
        if self.starts(with: [0xFF, 0xD8, 0xFF]) {
            return "JPEG"
        }
        
        // PNG signature: 89 50 4E 47 0D 0A 1A 0A
        if self.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return "PNG"
        }
        
        // GIF signature: "GIF87a" or "GIF89a"
        if let header = String(data: self.prefix(6), encoding: .ascii),
           header == "GIF87a" || header == "GIF89a" {
            return "GIF"
        }
        
        return nil // Tipo desconocido
    }
    
    func isPDF() -> Bool {
        return self.starts(with: [0x25, 0x50, 0x44, 0x46])
    }
    
    func isImage() -> Bool {
        return self.starts(with: [0xFF, 0xD8, 0xFF]) || self.starts(with: [0x89, 0x50, 0x4E, 0x47])
    }

    func drawPDFfromData(size: CGSize? = nil, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        guard let dataProvider = CGDataProvider(data: self as CFData),
              let pdfDocument = CGPDFDocument(dataProvider),
              let pdfPage = pdfDocument.page(at: 1) else {
            return nil
        }

        let pageRect = pdfPage.getBoxRect(.mediaBox)
        let renderSize = size ?? pageRect.size
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = scale

        let renderer = UIGraphicsImageRenderer(size: renderSize, format: rendererFormat)

        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: renderSize))
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            let context = ctx.cgContext

            context.saveGState()

            // Scale the context to fit the page
            let scaleX = renderSize.width / pageRect.width
            let scaleY = renderSize.height / pageRect.height
            context.scaleBy(x: scaleX, y: scaleY)

            context.drawPDFPage(pdfPage)

            context.restoreGState()
        }

        return img
    }
}

extension WKWebView {
    func loadPDFData(_ data: Data) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.pdf")

        do {
            try data.write(to: tempURL)

            let request = URLRequest(url: tempURL)
            self.load(request)
        } catch {
            print("Error al escribir PDF en archivo temporal: \(error)")
        }
    }
}

extension String {
    func redAsterisks() -> NSMutableAttributedString {
        
        let mainString = self
        let asteriskRange = (mainString as NSString).range(of: "*")
        
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: asteriskRange)

        return mutableAttributedString
    }
    
    func replacingLastOccurrence(of target: String, with string: String) -> String {
        if let range = self.range(of: target, options: .backwards) {
            return self.replacingCharacters(in: range, with: string)
        }
        return self
    }
}

extension Data {
    func pdfDataToUIImage(pageNumber: Int = 0) -> UIImage? {
          guard let pdfDocument = PDFDocument(data: self),
                let page = pdfDocument.page(at: pageNumber) else {
              return nil
          }

          let pageRect = page.bounds(for: .mediaBox)
          let renderer = UIGraphicsImageRenderer(size: pageRect.size)

          let image = renderer.image { ctx in
              let context = ctx.cgContext

              context.setFillColor(UIColor.white.cgColor)
              context.fill(pageRect)

              // Corregir el sistema de coordenadas (volteo vertical)
              context.saveGState()
              context.translateBy(x: 0, y: pageRect.size.height)
              context.scaleBy(x: 1.0, y: -1.0)

              page.draw(with: .mediaBox, to: context)

              context.restoreGState()
          }

          return image
      }
}

extension URL {
    
    func getImagefromURL() -> UIImage? {
        guard let document = CGPDFDocument(self as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }

        return img
    }
}
