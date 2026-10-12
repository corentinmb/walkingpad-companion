import AppKit
import Foundation

// Run from the repository root: swift scripts/make-icon.swift
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let directory = root.appendingPathComponent("walkingpad-client/Assets.xcassets/AppIcon.appiconset")
let variants = [(16,"icon_16.png"),(32,"icon_32.png"),(32,"icon_32-1.png"),(64,"icon_64.png"),(128,"icon_128.png"),(256,"icon_256.png"),(256,"icon_256-1.png"),(512,"icon_512.png"),(512,"icon_512-1.png"),(1024,"icon_1024.png")]
for (size, name) in variants {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let transform = AffineTransform(scale: CGFloat(size) / 1024)
    (transform as NSAffineTransform).concat()
    NSColor(red: 0.08, green: 0.13, blue: 0.11, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 64, y: 64, width: 896, height: 896), xRadius: 200, yRadius: 200).fill()
    let track = NSBezierPath(ovalIn: NSRect(x: 202, y: 202, width: 620, height: 620))
    track.lineWidth = 50
    NSColor(red: 0.17, green: 0.26, blue: 0.21, alpha: 1).setStroke()
    track.stroke()
    let ring = NSBezierPath()
    ring.appendArc(withCenter: NSPoint(x: 512, y: 512), radius: 310, startAngle: 90, endAngle: -170, clockwise: true)
    ring.lineWidth = 50
    ring.lineCapStyle = .round
    NSColor(red: 0.51, green: 0.85, blue: 0.59, alpha: 1).setStroke()
    ring.stroke()
    NSColor(red: 0.70, green: 0.93, blue: 0.61, alpha: 1).setFill()
    for (x, y, angle) in [(CGFloat(418),CGFloat(452),CGFloat(-18)), (CGFloat(578),CGFloat(562),CGFloat(18))] {
        NSGraphicsContext.saveGraphicsState()
        let placement = NSAffineTransform()
        placement.translateX(by: x, yBy: y)
        placement.rotate(byDegrees: angle)
        placement.concat()
        NSBezierPath(roundedRect: NSRect(x: -40, y: -60, width: 80, height: 150), xRadius: 40, yRadius: 40).fill()
        NSBezierPath(ovalIn: NSRect(x: -32, y: -122, width: 64, height: 48)).fill()
        NSGraphicsContext.restoreGraphicsState()
    }
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .png, properties: [:])!.write(to: directory.appendingPathComponent(name))
}
try Data(contentsOf: directory.appendingPathComponent("icon_1024.png")).write(to: root.appendingPathComponent("site/assets/icon.png"))
