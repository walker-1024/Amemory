//
//  PDFProcessor.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/12/3.
//

import Foundation
import PDFKit

class PDFProcessor {

    static let shared = PDFProcessor()

    private init() { }

    func convertMultiPageToSinglePage(data oldPdfData: Data) -> Data? {
        guard let oldPdf = PDFDocument(data: oldPdfData) else { return nil }
        if oldPdf.pageCount == 0 { return nil }
        if oldPdf.pageCount == 1 { return oldPdfData }

        var allPages: [PDFPage] = []
        var totalHeight: CGFloat = 0
        var width: CGFloat = 0
        for i in 0..<oldPdf.pageCount {
            guard let page = oldPdf.page(at: i) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            width = bounds.width
            totalHeight += bounds.height
            allPages.append(page)
        }

        let pdfBounds = CGRect(x: 0, y: 0, width: width, height: totalHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pdfBounds)
        let data = renderer.pdfData { context in
            context.beginPage()
            var offset: CGFloat = 0
            for page in allPages {
                let pageBounds = page.bounds(for: .mediaBox)
                context.cgContext.translateBy(x: 0, y: offset + pageBounds.height)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                page.draw(with: .mediaBox, to: context.cgContext)
                context.cgContext.translateBy(x: 0, y: offset + pageBounds.height)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                offset += pageBounds.height
            }
        }
        return data
    }

    func convertPdfToImage(data pdfData: Data) -> Data? {
        guard let pdf = PDFDocument(data: pdfData) else { return nil }
        guard pdf.pageCount > 0 else { return nil }

        var allPages: [PDFPage] = []
        var totalHeight: CGFloat = 0
        var width: CGFloat = 0
        for i in 0..<pdf.pageCount {
            guard let page = pdf.page(at: i) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            width = bounds.width
            totalHeight += bounds.height
            allPages.append(page)
        }

        let rendered = UIGraphicsImageRenderer(size: CGSize(width: width, height: totalHeight))
        let data = rendered.pngData { context in
            var offset: CGFloat = 0
            for page in allPages {
                let pageBounds = page.bounds(for: .mediaBox)
                context.cgContext.translateBy(x: 0, y: offset + pageBounds.height)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                page.draw(with: .mediaBox, to: context.cgContext)
                context.cgContext.translateBy(x: 0, y: offset + pageBounds.height)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                offset += pageBounds.height
            }
        }
        return data
    }

    func convertSinglePageToMultiPage(data singlePagePdfData: Data, ratioWidth: CGFloat, ratioHeight: CGFloat) -> Data? {
        guard let singlePagePdf = PDFDocument(data: singlePagePdfData) else { return nil }
        guard let oldPage = singlePagePdf.page(at: 0) else { return nil }

        let oldPdfWidth = oldPage.bounds(for: .mediaBox).width
        let oldPdfHeight = oldPage.bounds(for: .mediaBox).height
        let pageHeight = oldPdfWidth * ratioHeight / ratioWidth
        let pageNum = Int(ceil(oldPdfHeight / pageHeight))

        let newPdfBounds = CGRect(x: 0, y: 0, width: oldPdfWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: newPdfBounds)
        let data = renderer.pdfData { context in
            for i in 0..<pageNum {
                let offset = pageHeight * CGFloat(i)
                context.beginPage()
                context.cgContext.translateBy(x: 0, y: oldPdfHeight - offset)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                oldPage.draw(with: .mediaBox, to: context.cgContext)
            }
        }
        return data
    }
}
