#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import Cocoa
import FlutterMacOS
#endif
import CoreGraphics

public class SwiftPdfxPlugin: NSObject, FlutterPlugin, PdfxApi {
    let registrar: FlutterPluginRegistrar
    static let invalid = NSNumber(value: -1)
    let dispQueue = DispatchQueue(label: "io.scer.pdf_renderer")

    let documents = DocumentRepository()
    let pages = PageRepository()
    var textures: [Int64: PdfPageTexture] = [:]

    init(registrar: FlutterPluginRegistrar) {
      self.registrar = registrar
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
            let messenger: FlutterBinaryMessenger = registrar.messenger()
        #elseif os(macOS)
            let messenger: FlutterBinaryMessenger = registrar.messenger
        #endif
        let api: PdfxApi & NSObjectProtocol = SwiftPdfxPlugin.init(registrar: registrar)
        PdfxApiSetup(messenger, api);
    }

    public func openDocumentDataMessage(_ message: OpenDataMessage, completion: @escaping (OpenReply?, FlutterError?) -> Void) {
        guard let data = message.data else {
            return completion(nil, FlutterError(code: "RENDER_ERROR",
                                       message: "Arguments not sended",
                                       details: nil))
        }
        guard let renderer = openDataDocument(data: data.data) else {
            return completion(nil, FlutterError(code: "RENDER_ERROR",
                                       message: "Invalid PDF format",
                                       details: nil))
        }

        let document = documents.register(renderer: renderer);
        let result = OpenReply.init()
        result.id = document.id
        result.pagesCount = NSNumber.init(value: document.pagesCount)

        completion(result, nil);
    }

    public func openDocumentFileMessage(_ message: OpenPathMessage, completion: @escaping (OpenReply?, FlutterError?) -> Void) {
        guard let pdfFilePath = message.path else {
            return completion(nil, FlutterError(code: "RENDER_ERROR",
                                       message: "Arguments not sended",
                                       details: nil))
        }
        guard let renderer = openFileDocument(pdfFilePath: pdfFilePath)  else {
            return completion(nil, FlutterError(code: "RENDER_ERROR",
                                       message: "Invalid PDF format",
                                       details: nil))
        }

        let document = documents.register(renderer: renderer);
        let result = OpenReply.init()
        result.id = document.id
        result.pagesCount = NSNumber.init(value: document.pagesCount)

        completion(result, nil);
    }

    public func openDocumentAssetMessage(_ message: OpenPathMessage, completion: @escaping (OpenReply?, FlutterError?) -> Void) {
        guard let name = message.path else {
            return completion(nil, FlutterError(code: "RENDER_ERROR",
                                       message: "Arguments not sended",
                                       details: nil))
        }
        guard let renderer = openAssetDocument(name: name)  else {
            return completion(nil, FlutterError(code: "RENDER_ERROR",
                                       message: "Invalid PDF format",
                                       details: nil))
        }

        let document = documents.register(renderer: renderer);
        let result = OpenReply.init()
        result.id = document.id
        result.pagesCount = NSNumber.init(value: document.pagesCount)

        completion(result, nil);
    }

    public func closeDocumentMessage(_ message: IdMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let id = message.id {
            documents.close(id: id)
        }
    }

    public func getPageMessage(_ message: GetPageMessage, completion: @escaping (GetPageReply?, FlutterError?) -> Void) {
        do {
            let documentId = message.documentId
            let pageNumber = message.pageNumber

            let result = GetPageReply.init();

            let renderer = try documents.get(id: documentId!).openPage(pageNumber: pageNumber as! Int)
            if (renderer == nil) {
                return completion(nil, FlutterError(code: "RENDER_ERROR",
                                           message: "Unexpected error: renderer is nil.",
                                           details: nil))
            }

            let page = pages.register(documentId: documentId!, renderer: renderer!)
            result.id = page.id
            result.width = NSNumber.init(value: page.width)
            result.height = NSNumber.init(value: page.height)
            completion(result, nil)
        } catch let err {
            return completion(nil, FlutterError(code: "RENDER_ERROR",
                                message: "Unexpected error: \(err).",
                                details: nil))
        }
    }

    public func renderPageMessage(_ message: RenderPageMessage, completion: @escaping (RenderPageReply?, FlutterError?) -> Void) {
        // Set crop if required
        var cropZone: CGRect? = nil
        if (message.crop!.boolValue){
            let cWidth = message.cropWidth!.intValue
            let cHeight = message.cropHeight!.intValue
            if (cWidth != message.width!.intValue || cHeight != message.height!.intValue){
                cropZone = CGRect(x: message.cropX as! Int,
                                  y: message.cropY as! Int,
                                  width: cWidth,
                                  height: cHeight)
            }
        }

        dispQueue.async {
            let result = RenderPageReply.init()
            do {
                let page = try self.pages.get(id: message.pageId!)
                if let data = page.render(
                    width: message.width!.intValue,
                    height: message.height!.intValue,
                    crop: cropZone,
                    compressFormat: CompressFormat(rawValue: message.format!.intValue)!,
                    backgroundColor: message.backgroundColor!,
                    quality: message.quality!.intValue
                ) {
                    result.width = NSNumber.init(value: data.width)
                    result.height = NSNumber.init(value: data.height)
                    result.path = data.path
                }
            } catch {
                completion(nil, FlutterError(code: "RENDER_ERROR",
                                    message: "Unexpected error: \(error).",
                    details: nil))
            }
            DispatchQueue.main.async {
                completion(result.path != nil ? result : nil, nil)
            }
        }
    }

    public func closePageMessage(_ message: IdMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let id = message.id {
            pages.close(id: id)
        }
    }

    public func registerTextureWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> RegisterTextureReply? {
        let result = RegisterTextureReply.init()
        let pageTex = PdfPageTexture(registrar: registrar)
        #if os(iOS)
            let texId = registrar.textures().register(pageTex)
        #elseif os(macOS)
            let texId = registrar.textures.register(pageTex)
        #endif
        textures[texId] = pageTex
        pageTex.texId = texId
        result.id = NSNumber.init(value: texId)
        return result
    }

    public func unregisterTextureMessage(_ message: UnregisterTextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        let texId = message.id?.int64Value
        #if os(iOS)
            registrar.textures().unregisterTexture(texId!)
        #elseif os(macOS)
            registrar.textures.unregisterTexture(texId!)
        #endif
            textures[texId!] = nil
    }

    public func resizeTextureMessage(_ message: ResizeTextureMessage, completion: @escaping (FlutterError?) -> Void) {
        let texId = message.textureId?.int64Value
        guard let pageTex = textures[texId!] else {
            return completion(FlutterError(code: "RENDER_ERROR",
                                           message: "No texture of texId=\(String(describing: texId!))",
                                       details: nil))
        }
        let width = message.width?.intValue,
            height = message.height?.intValue
        pageTex.resize(width: width!, height: height!)
        return completion(nil)
    }

    public func updateTextureMessage(_ message: UpdateTextureMessage, completion: @escaping (FlutterError?) -> Void) {
        let texId = message.textureId?.int64Value
        let pageId = message.pageId!
        let destX = message.destinationX?.intValue
        let destY = message.destinationY?.intValue
        let width = message.width?.intValue
        let height = message.height?.intValue
        let srcX = message.sourceX?.intValue
        let srcY = message.sourceY?.intValue
        let fw = message.fullWidth?.doubleValue
        let fh = message.fullHeight?.doubleValue
        let backgroundColor = message.backgroundColor
        let allowAntialiasing = message.allowAntiAliasing?.boolValue

        let tw = message.textureWidth?.intValue
        let th = message.textureHeight?.intValue

        let pageTex = textures[texId!]!

        if tw != nil && th != nil {
          pageTex.resize(width: tw!, height: th!)
        }

        if width == nil || height == nil {
            return completion(FlutterError(code: "RENDER_ERROR",
                                           message: "width/height nil",
                                       details: nil))
        }
        do {
            let page = try self.pages.get(id: pageId)

            try pageTex.updateTex(
                page: page.renderer,
                destX: destX!,
                destY: destY!,
                width: width!,
                height: height!,
                srcX: srcX!,
                srcY: srcY!,
                fullWidth: fw,
                fullHeight: fh,
                backgroundColor: backgroundColor,
                allowAntialiasing: allowAntialiasing!
            )
            return completion(nil)
        } catch {
            return completion(FlutterError(code: "RENDER_ERROR",
                                           message: "Cannot render texture",
                                       details: nil))
        }

    }

    func openDataDocument(data: Data) -> CGPDFDocument? {
        guard let datProv = CGDataProvider(data: data as CFData) else { return nil }
        return CGPDFDocument(datProv)
    }

    func openFileDocument(pdfFilePath: String) -> CGPDFDocument? {
        return CGPDFDocument(URL(fileURLWithPath: pdfFilePath) as CFURL)
    }

    func openAssetDocument(name: String) -> CGPDFDocument? {
        #if os(iOS)
        guard let path = Bundle.main.path(forResource: "Frameworks/App.framework/flutter_assets/" + name, ofType: "") else {
            return nil
        }
        #elseif os(macOS)
        let path = Bundle.main.bundlePath + "/Contents/Frameworks/App.framework/Resources/flutter_assets/" + name;
        #endif

        return openFileDocument(pdfFilePath: path)
    }
}

enum PdfRenderError : Error {
  case operationFailed(String)
  case invalidArgument(String)
  case notSupported(String)
}

class PdfPageTexture : NSObject {
  var pixBuf : CVPixelBuffer?
  weak var registrar: FlutterPluginRegistrar?
  var texId: Int64 = 0
  var texWidth: Int = 0
  var texHeight: Int = 0

  init(registrar: FlutterPluginRegistrar?) {
    self.registrar = registrar
  }

  func resize(width: Int, height: Int) {
    if self.texWidth == width && self.texHeight == height {
      return
    }
    self.texWidth = width
    self.texHeight = height
  }

  func updateTex(
    page: CGPDFPage,
    destX: Int,
    destY: Int,
    width: Int,
    height: Int,
    srcX: Int,
    srcY: Int,
    fullWidth: Double?,
    fullHeight: Double?,
    backgroundColor: String?,
    allowAntialiasing: Bool = true
  ) throws {

    let rotatedSize = page.getRotatedSize()
    let fw = fullWidth ?? Double(rotatedSize.width)
    let fh = fullHeight ?? Double(rotatedSize.height)
    let sx = CGFloat(fw) / rotatedSize.width
    let sy = CGFloat(fh) / rotatedSize.height

    var pixBuf: CVPixelBuffer?
    let options = [
      kCVPixelBufferCGImageCompatibilityKey as String: true,
      kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
      kCVPixelBufferIOSurfacePropertiesKey as String: [:]
      ] as [String : Any]
    let cvRet = CVPixelBufferCreate(kCFAllocatorDefault, texWidth, texHeight, kCVPixelFormatType_32BGRA, options as CFDictionary?, &pixBuf)
    if pixBuf == nil {
      throw PdfRenderError.operationFailed("CVPixelBufferCreate failed: result code=\(cvRet)")
    }

    let lockFlags = CVPixelBufferLockFlags(rawValue: 0)
    let _ = CVPixelBufferLockBaseAddress(pixBuf!, lockFlags)
    defer {
      CVPixelBufferUnlockBaseAddress(pixBuf!, lockFlags)
    }

    let bufferAddress = CVPixelBufferGetBaseAddress(pixBuf!)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixBuf!)
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: bufferAddress?.advanced(by: destX * 4 + destY * bytesPerRow),
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: bytesPerRow,
                            space: rgbColorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)


    if backgroundColor != nil {
        #if os(iOS)
            context?.setFillColor(UIColor(hexString: backgroundColor!).cgColor)
        #elseif os(macOS)
            context?.setFillColor(NSColor(hexString: backgroundColor!).cgColor)
        #endif
        context?.fill(CGRect(x: 0, y: 0, width: width, height: height))
    }

    context?.setAllowsAntialiasing(allowAntialiasing)

    context?.translateBy(x: CGFloat(-srcX), y: CGFloat(Double(srcY + height) - fh))
    context?.scaleBy(x: sx, y: sy)
    context?.concatenate(page.getRotationTransform())
    context?.drawPDFPage(page)
    context?.flush()

    self.pixBuf = pixBuf
    #if os(iOS)
      registrar?.textures().textureFrameAvailable(texId)
    #elseif os(macOS)
      registrar?.textures.textureFrameAvailable(texId)
    #endif
  }
}

extension PdfPageTexture : FlutterTexture {
  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    return pixBuf != nil ? Unmanaged<CVPixelBuffer>.passRetained(pixBuf!) : nil
  }
}
