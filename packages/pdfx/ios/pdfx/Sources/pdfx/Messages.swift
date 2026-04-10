// Manually translated from Pigeon-generated Obj-C (messages.h/m) to Swift.
// Preserves the exact same NSObject-based API so SwiftPdfxPlugin needs no changes.

import Foundation
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

// MARK: - Helper functions

private func wrapResult(_ result: Any?, _ error: FlutterError?) -> [Any?] {
    if let error = error {
        return [error.code, error.message, error.details]
    }
    return [result as Any]
}

private func getNullableObject(_ array: [Any?], _ index: Int) -> Any? {
    let result = array[index]
    return result is NSNull ? nil : result
}

// MARK: - Message classes

@objc public class OpenDataMessage: NSObject {
    @objc public var data: FlutterStandardTypedData?
    @objc public var password: String?

    @objc public static func make(withData data: FlutterStandardTypedData?, password: String?) -> OpenDataMessage {
        let msg = OpenDataMessage()
        msg.data = data
        msg.password = password
        return msg
    }
    static func fromList(_ list: [Any?]) -> OpenDataMessage {
        let msg = OpenDataMessage()
        msg.data = getNullableObject(list, 0) as? FlutterStandardTypedData
        msg.password = getNullableObject(list, 1) as? String
        return msg
    }
    func toList() -> [Any?] { [data ?? NSNull(), password ?? NSNull()] }
}

@objc public class OpenPathMessage: NSObject {
    @objc public var path: String?
    @objc public var password: String?

    @objc public static func make(withPath path: String?, password: String?) -> OpenPathMessage {
        let msg = OpenPathMessage()
        msg.path = path
        msg.password = password
        return msg
    }
    static func fromList(_ list: [Any?]) -> OpenPathMessage {
        let msg = OpenPathMessage()
        msg.path = getNullableObject(list, 0) as? String
        msg.password = getNullableObject(list, 1) as? String
        return msg
    }
    func toList() -> [Any?] { [path ?? NSNull(), password ?? NSNull()] }
}

@objc public class OpenReply: NSObject {
    @objc public var id: String?
    @objc public var pagesCount: NSNumber?

    static func fromList(_ list: [Any?]) -> OpenReply {
        let msg = OpenReply()
        msg.id = getNullableObject(list, 0) as? String
        msg.pagesCount = getNullableObject(list, 1) as? NSNumber
        return msg
    }
    func toList() -> [Any?] { [id ?? NSNull(), pagesCount ?? NSNull()] }
}

@objc public class IdMessage: NSObject {
    @objc public var id: String?

    static func fromList(_ list: [Any?]) -> IdMessage {
        let msg = IdMessage()
        msg.id = getNullableObject(list, 0) as? String
        return msg
    }
    func toList() -> [Any?] { [id ?? NSNull()] }
}

@objc public class GetPageMessage: NSObject {
    @objc public var documentId: String?
    @objc public var pageNumber: NSNumber?
    @objc public var autoCloseAndroid: NSNumber?

    static func fromList(_ list: [Any?]) -> GetPageMessage {
        let msg = GetPageMessage()
        msg.documentId = getNullableObject(list, 0) as? String
        msg.pageNumber = getNullableObject(list, 1) as? NSNumber
        msg.autoCloseAndroid = getNullableObject(list, 2) as? NSNumber
        return msg
    }
    func toList() -> [Any?] { [documentId ?? NSNull(), pageNumber ?? NSNull(), autoCloseAndroid ?? NSNull()] }
}

@objc public class GetPageReply: NSObject {
    @objc public var id: String?
    @objc public var width: NSNumber?
    @objc public var height: NSNumber?

    static func fromList(_ list: [Any?]) -> GetPageReply {
        let msg = GetPageReply()
        msg.id = getNullableObject(list, 0) as? String
        msg.width = getNullableObject(list, 1) as? NSNumber
        msg.height = getNullableObject(list, 2) as? NSNumber
        return msg
    }
    func toList() -> [Any?] { [id ?? NSNull(), width ?? NSNull(), height ?? NSNull()] }
}

@objc public class RenderPageMessage: NSObject {
    @objc public var pageId: String?
    @objc public var width: NSNumber?
    @objc public var height: NSNumber?
    @objc public var format: NSNumber?
    @objc public var backgroundColor: String?
    @objc public var crop: NSNumber?
    @objc public var cropX: NSNumber?
    @objc public var cropY: NSNumber?
    @objc public var cropHeight: NSNumber?
    @objc public var cropWidth: NSNumber?
    @objc public var quality: NSNumber?
    @objc public var forPrint: NSNumber?

    static func fromList(_ list: [Any?]) -> RenderPageMessage {
        let msg = RenderPageMessage()
        msg.pageId = getNullableObject(list, 0) as? String
        msg.width = getNullableObject(list, 1) as? NSNumber
        msg.height = getNullableObject(list, 2) as? NSNumber
        msg.format = getNullableObject(list, 3) as? NSNumber
        msg.backgroundColor = getNullableObject(list, 4) as? String
        msg.crop = getNullableObject(list, 5) as? NSNumber
        msg.cropX = getNullableObject(list, 6) as? NSNumber
        msg.cropY = getNullableObject(list, 7) as? NSNumber
        msg.cropHeight = getNullableObject(list, 8) as? NSNumber
        msg.cropWidth = getNullableObject(list, 9) as? NSNumber
        msg.quality = getNullableObject(list, 10) as? NSNumber
        msg.forPrint = getNullableObject(list, 11) as? NSNumber
        return msg
    }
    func toList() -> [Any?] {
        [pageId ?? NSNull(), width ?? NSNull(), height ?? NSNull(), format ?? NSNull(),
         backgroundColor ?? NSNull(), crop ?? NSNull(), cropX ?? NSNull(), cropY ?? NSNull(),
         cropHeight ?? NSNull(), cropWidth ?? NSNull(), quality ?? NSNull(), forPrint ?? NSNull()]
    }
}

@objc public class RenderPageReply: NSObject {
    @objc public var width: NSNumber?
    @objc public var height: NSNumber?
    @objc public var path: String?
    @objc public var data: FlutterStandardTypedData?

    static func fromList(_ list: [Any?]) -> RenderPageReply {
        let msg = RenderPageReply()
        msg.width = getNullableObject(list, 0) as? NSNumber
        msg.height = getNullableObject(list, 1) as? NSNumber
        msg.path = getNullableObject(list, 2) as? String
        msg.data = getNullableObject(list, 3) as? FlutterStandardTypedData
        return msg
    }
    func toList() -> [Any?] { [width ?? NSNull(), height ?? NSNull(), path ?? NSNull(), data ?? NSNull()] }
}

@objc public class RegisterTextureReply: NSObject {
    @objc public var id: NSNumber?

    static func fromList(_ list: [Any?]) -> RegisterTextureReply {
        let msg = RegisterTextureReply()
        msg.id = getNullableObject(list, 0) as? NSNumber
        return msg
    }
    func toList() -> [Any?] { [id ?? NSNull()] }
}

@objc public class UpdateTextureMessage: NSObject {
    @objc public var documentId: String?
    @objc public var pageNumber: NSNumber?
    @objc public var pageId: String?
    @objc public var textureId: NSNumber?
    @objc public var width: NSNumber?
    @objc public var height: NSNumber?
    @objc public var backgroundColor: String?
    @objc public var sourceX: NSNumber?
    @objc public var sourceY: NSNumber?
    @objc public var destinationX: NSNumber?
    @objc public var destinationY: NSNumber?
    @objc public var fullWidth: NSNumber?
    @objc public var fullHeight: NSNumber?
    @objc public var textureWidth: NSNumber?
    @objc public var textureHeight: NSNumber?
    @objc public var allowAntiAliasing: NSNumber?

    static func fromList(_ list: [Any?]) -> UpdateTextureMessage {
        let msg = UpdateTextureMessage()
        msg.documentId = getNullableObject(list, 0) as? String
        msg.pageNumber = getNullableObject(list, 1) as? NSNumber
        msg.pageId = getNullableObject(list, 2) as? String
        msg.textureId = getNullableObject(list, 3) as? NSNumber
        msg.width = getNullableObject(list, 4) as? NSNumber
        msg.height = getNullableObject(list, 5) as? NSNumber
        msg.backgroundColor = getNullableObject(list, 6) as? String
        msg.sourceX = getNullableObject(list, 7) as? NSNumber
        msg.sourceY = getNullableObject(list, 8) as? NSNumber
        msg.destinationX = getNullableObject(list, 9) as? NSNumber
        msg.destinationY = getNullableObject(list, 10) as? NSNumber
        msg.fullWidth = getNullableObject(list, 11) as? NSNumber
        msg.fullHeight = getNullableObject(list, 12) as? NSNumber
        msg.textureWidth = getNullableObject(list, 13) as? NSNumber
        msg.textureHeight = getNullableObject(list, 14) as? NSNumber
        msg.allowAntiAliasing = getNullableObject(list, 15) as? NSNumber
        return msg
    }
    func toList() -> [Any?] {
        [documentId ?? NSNull(), pageNumber ?? NSNull(), pageId ?? NSNull(), textureId ?? NSNull(),
         width ?? NSNull(), height ?? NSNull(), backgroundColor ?? NSNull(),
         sourceX ?? NSNull(), sourceY ?? NSNull(), destinationX ?? NSNull(), destinationY ?? NSNull(),
         fullWidth ?? NSNull(), fullHeight ?? NSNull(), textureWidth ?? NSNull(), textureHeight ?? NSNull(),
         allowAntiAliasing ?? NSNull()]
    }
}

@objc public class ResizeTextureMessage: NSObject {
    @objc public var textureId: NSNumber?
    @objc public var width: NSNumber?
    @objc public var height: NSNumber?

    static func fromList(_ list: [Any?]) -> ResizeTextureMessage {
        let msg = ResizeTextureMessage()
        msg.textureId = getNullableObject(list, 0) as? NSNumber
        msg.width = getNullableObject(list, 1) as? NSNumber
        msg.height = getNullableObject(list, 2) as? NSNumber
        return msg
    }
    func toList() -> [Any?] { [textureId ?? NSNull(), width ?? NSNull(), height ?? NSNull()] }
}

@objc public class UnregisterTextureMessage: NSObject {
    @objc public var id: NSNumber?

    static func fromList(_ list: [Any?]) -> UnregisterTextureMessage {
        let msg = UnregisterTextureMessage()
        msg.id = getNullableObject(list, 0) as? NSNumber
        return msg
    }
    func toList() -> [Any?] { [id ?? NSNull()] }
}

// MARK: - Codec

private class PdfxApiCodecReader: FlutterStandardReader {
    override func readValue(ofType type: UInt8) -> Any? {
        switch type {
        case 128: return GetPageMessage.fromList(readValue() as! [Any?])
        case 129: return GetPageReply.fromList(readValue() as! [Any?])
        case 130: return IdMessage.fromList(readValue() as! [Any?])
        case 131: return OpenDataMessage.fromList(readValue() as! [Any?])
        case 132: return OpenPathMessage.fromList(readValue() as! [Any?])
        case 133: return OpenReply.fromList(readValue() as! [Any?])
        case 134: return RegisterTextureReply.fromList(readValue() as! [Any?])
        case 135: return RenderPageMessage.fromList(readValue() as! [Any?])
        case 136: return RenderPageReply.fromList(readValue() as! [Any?])
        case 137: return ResizeTextureMessage.fromList(readValue() as! [Any?])
        case 138: return UnregisterTextureMessage.fromList(readValue() as! [Any?])
        case 139: return UpdateTextureMessage.fromList(readValue() as! [Any?])
        default: return super.readValue(ofType: type)
        }
    }
}

private class PdfxApiCodecWriter: FlutterStandardWriter {
    override func writeValue(_ value: Any) {
        if let v = value as? GetPageMessage { writeByte(128); writeValue(v.toList()) }
        else if let v = value as? GetPageReply { writeByte(129); writeValue(v.toList()) }
        else if let v = value as? IdMessage { writeByte(130); writeValue(v.toList()) }
        else if let v = value as? OpenDataMessage { writeByte(131); writeValue(v.toList()) }
        else if let v = value as? OpenPathMessage { writeByte(132); writeValue(v.toList()) }
        else if let v = value as? OpenReply { writeByte(133); writeValue(v.toList()) }
        else if let v = value as? RegisterTextureReply { writeByte(134); writeValue(v.toList()) }
        else if let v = value as? RenderPageMessage { writeByte(135); writeValue(v.toList()) }
        else if let v = value as? RenderPageReply { writeByte(136); writeValue(v.toList()) }
        else if let v = value as? ResizeTextureMessage { writeByte(137); writeValue(v.toList()) }
        else if let v = value as? UnregisterTextureMessage { writeByte(138); writeValue(v.toList()) }
        else if let v = value as? UpdateTextureMessage { writeByte(139); writeValue(v.toList()) }
        else { super.writeValue(value) }
    }
}

private class PdfxApiCodecReaderWriter: FlutterStandardReaderWriter {
    override func writer(with data: NSMutableData) -> FlutterStandardWriter {
        PdfxApiCodecWriter(data: data)
    }
    override func reader(with data: Data) -> FlutterStandardReader {
        PdfxApiCodecReader(data: data)
    }
}

// MARK: - Protocol & Setup

@objc public protocol PdfxApi {
    func openDocumentDataMessage(_ message: OpenDataMessage, completion: @escaping (OpenReply?, FlutterError?) -> Void)
    func openDocumentFileMessage(_ message: OpenPathMessage, completion: @escaping (OpenReply?, FlutterError?) -> Void)
    func openDocumentAssetMessage(_ message: OpenPathMessage, completion: @escaping (OpenReply?, FlutterError?) -> Void)
    func closeDocumentMessage(_ message: IdMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    func getPageMessage(_ message: GetPageMessage, completion: @escaping (GetPageReply?, FlutterError?) -> Void)
    func renderPageMessage(_ message: RenderPageMessage, completion: @escaping (RenderPageReply?, FlutterError?) -> Void)
    func closePageMessage(_ message: IdMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    func registerTextureWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> RegisterTextureReply?
    func updateTextureMessage(_ message: UpdateTextureMessage, completion: @escaping (FlutterError?) -> Void)
    func resizeTextureMessage(_ message: ResizeTextureMessage, completion: @escaping (FlutterError?) -> Void)
    func unregisterTextureMessage(_ message: UnregisterTextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
}

private var _codecInstance: FlutterStandardMessageCodec?

public func PdfxApiGetCodec() -> NSObject & FlutterMessageCodec {
    if _codecInstance == nil {
        _codecInstance = FlutterStandardMessageCodec(readerWriter: PdfxApiCodecReaderWriter())
    }
    return _codecInstance!
}

public func PdfxApiSetup(_ binaryMessenger: FlutterBinaryMessenger, _ api: (NSObjectProtocol & PdfxApi)?) {
    let codec = PdfxApiGetCodec()

    let openDocumentDataChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.openDocumentData", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        openDocumentDataChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! OpenDataMessage
            api.openDocumentDataMessage(argMessage) { output, error in callback(wrapResult(output, error)) }
        }
    } else { openDocumentDataChannel.setMessageHandler(nil) }

    let openDocumentFileChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.openDocumentFile", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        openDocumentFileChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! OpenPathMessage
            api.openDocumentFileMessage(argMessage) { output, error in callback(wrapResult(output, error)) }
        }
    } else { openDocumentFileChannel.setMessageHandler(nil) }

    let openDocumentAssetChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.openDocumentAsset", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        openDocumentAssetChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! OpenPathMessage
            api.openDocumentAssetMessage(argMessage) { output, error in callback(wrapResult(output, error)) }
        }
    } else { openDocumentAssetChannel.setMessageHandler(nil) }

    let closeDocumentChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.closeDocument", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        closeDocumentChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! IdMessage
            var error: FlutterError?
            api.closeDocumentMessage(argMessage, error: &error)
            callback(wrapResult(nil, error))
        }
    } else { closeDocumentChannel.setMessageHandler(nil) }

    let getPageChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.getPage", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        getPageChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! GetPageMessage
            api.getPageMessage(argMessage) { output, error in callback(wrapResult(output, error)) }
        }
    } else { getPageChannel.setMessageHandler(nil) }

    let renderPageChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.renderPage", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        renderPageChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! RenderPageMessage
            api.renderPageMessage(argMessage) { output, error in callback(wrapResult(output, error)) }
        }
    } else { renderPageChannel.setMessageHandler(nil) }

    let closePageChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.closePage", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        closePageChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! IdMessage
            var error: FlutterError?
            api.closePageMessage(argMessage, error: &error)
            callback(wrapResult(nil, error))
        }
    } else { closePageChannel.setMessageHandler(nil) }

    let registerTextureChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.registerTexture", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        registerTextureChannel.setMessageHandler { _, callback in
            var error: FlutterError?
            let output = api.registerTextureWithError(&error)
            callback(wrapResult(output, error))
        }
    } else { registerTextureChannel.setMessageHandler(nil) }

    let updateTextureChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.updateTexture", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        updateTextureChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! UpdateTextureMessage
            api.updateTextureMessage(argMessage) { error in callback(wrapResult(nil, error)) }
        }
    } else { updateTextureChannel.setMessageHandler(nil) }

    let resizeTextureChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.resizeTexture", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        resizeTextureChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! ResizeTextureMessage
            api.resizeTextureMessage(argMessage) { error in callback(wrapResult(nil, error)) }
        }
    } else { resizeTextureChannel.setMessageHandler(nil) }

    let unregisterTextureChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.PdfxApi.unregisterTexture", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
        unregisterTextureChannel.setMessageHandler { message, callback in
            let args = message as! [Any?]
            let argMessage = getNullableObject(args, 0) as! UnregisterTextureMessage
            var error: FlutterError?
            api.unregisterTextureMessage(argMessage, error: &error)
            callback(wrapResult(nil, error))
        }
    } else { unregisterTextureChannel.setMessageHandler(nil) }
}
