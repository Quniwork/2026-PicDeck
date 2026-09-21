// 把 SF Symbol 畫成黑色、透明底的 PNG，給 make_app_icon.py 當形狀用。
// 用法：swift tools/render_symbol.swift <符號名稱> <輸出路徑> [像素]
import AppKit

let args = CommandLine.arguments
let name = args[1], out = args[2]
let px = args.count > 3 ? CGFloat(Double(args[3])!) : 1400
let config = NSImage.SymbolConfiguration(pointSize: px, weight: .regular)
guard let base = NSImage(systemSymbolName: name, accessibilityDescription: nil)?.withSymbolConfiguration(config) else { fatalError("找不到符號 \(name)") }
let size = base.size
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor.black.set()
base.draw(in: NSRect(origin: .zero, size: size))
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("size", size)
