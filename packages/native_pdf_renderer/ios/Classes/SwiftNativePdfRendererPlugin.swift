#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import Cocoa
import FlutterMacOS
#endif
import CoreGraphics

public class SwiftNativePdfRendererPlugin: NSObject, FlutterPlugin, PdfRendererApi {
    static let invalid = NSNumber(value: -1)
    let dispQueue = DispatchQueue(label: "io.scer.native_pdf_renderer")

    let documents = DocumentRepository()
    let pages = PageRepository()

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
            let messenger: FlutterBinaryMessenger = registrar.messenger()
        #elseif os(macOS)
            let messenger: FlutterBinaryMessenger = registrar.messenger
        #endif
        let api: PdfRendererApi & NSObjectProtocol = SwiftNativePdfRendererPlugin.init()
        PdfRendererApiSetup(messenger, api);
    }

    public func openDocumentDataMessage(_ message: OpenDataMessage?, completion: @escaping (OpenReply?, FlutterError?) -> Void) {
        guard let data = message?.data else {
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

    public func openDocumentFileMessage(_ message: OpenPathMessage?, completion: @escaping (OpenReply?, FlutterError?) -> Void) {
        guard let pdfFilePath = message?.path else {
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

    public func openDocumentAssetMessage(_ message: OpenPathMessage?, completion: @escaping (OpenReply?, FlutterError?) -> Void) {
        guard let name = message?.path else {
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

    public func getPageMessage(_ message: GetPageMessage?, completion: @escaping (GetPageReply?, FlutterError?) -> Void) {
        do {
            let documentId = message!.documentId
            let pageNumber = message!.pageNumber

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

    public func renderPageMessage(_ message: RenderPageMessage?, completion: @escaping (RenderPageReply?, FlutterError?) -> Void) {
        // Set crop if required
        var cropZone: CGRect? = nil
        if (message!.crop!.boolValue){
            let cWidth = message!.cropWidth!.intValue
            let cHeight = message!.cropHeight!.intValue
            if (cWidth != message!.width!.intValue || cHeight != message!.height!.intValue){
                cropZone = CGRect(x: message!.cropX as! Int,
                                  y: message!.cropY as! Int,
                                  width: cWidth,
                                  height: cHeight)
            }
        }

        dispQueue.async {
            let result = RenderPageReply.init()
            do {
                let page = try self.pages.get(id: message!.pageId!)
                if let data = page.render(
                    width: message!.width!.intValue,
                    height: message!.height!.intValue,
                    crop: cropZone,
                    compressFormat: CompressFormat(rawValue: message!.format!.intValue)!,
                    backgroundColor: message!.backgroundColor!,
                    quality: message!.quality!.intValue
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
