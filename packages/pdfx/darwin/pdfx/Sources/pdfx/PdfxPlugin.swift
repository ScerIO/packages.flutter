#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import Foundation

/// Stable plugin entry point used by Flutter's generated registrants.
public final class PdfxPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftPdfxPlugin.register(with: registrar)
    }
}
