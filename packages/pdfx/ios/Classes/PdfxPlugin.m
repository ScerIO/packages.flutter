#import "PdfxPlugin.h"
#if __has_include(<pdfx/pdfx-Swift.h>)
#import <pdfx/pdfx-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pdfx-Swift.h"
#endif

@implementation PdfxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPdfxPlugin registerWithRegistrar:registrar];
}
@end
