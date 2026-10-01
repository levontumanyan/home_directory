#!/usr/bin/env swift
import Foundation
import PDFKit
import Vision

guard CommandLine.arguments.count > 1 else {
	fputs("Usage: pdf-ocr <path-to-pdf> [page-number]\n", stderr)
	exit(1)
}

let path = CommandLine.arguments[1]
let pageIndex = CommandLine.arguments.count > 2 ? (Int(CommandLine.arguments[2]) ?? 1) - 1 : 0
let url = URL(fileURLWithPath: path)

guard let doc = PDFDocument(url: url) else {
	fputs("Error: Could not open PDF document at \(path)\n", stderr)
	exit(1)
}

guard let page = doc.page(at: max(0, min(pageIndex, doc.pageCount - 1))) else {
	exit(0)
}

let pageRect = page.bounds(for: .mediaBox)
let renderer = NSImage(size: pageRect.size, flipped: false) { rect in
	guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
	page.draw(with: .mediaBox, to: ctx)
	return true
}

guard let cgImage = renderer.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
	exit(0)
}

var resultText = ""
let request = VNRecognizeTextRequest { req, err in
	guard let observations = req.results as? [VNRecognizedTextObservation] else { return }
	for obs in observations {
		if let top = obs.topCandidates(1).first {
			resultText += top.string + "\n"
		}
	}
}

request.recognitionLevel = .accurate
request.usesLanguageCorrection = true
let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
try? handler.perform([request])
print(resultText.trimmingCharacters(in: .whitespacesAndNewlines))
