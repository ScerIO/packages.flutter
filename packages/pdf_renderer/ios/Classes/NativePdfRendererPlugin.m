#import "NativePdfRendererPlugin.h"
#if __has_include(<pdf_renderer/pdf_renderer-Swift.h>)
#import <pdf_renderer/pdf_renderer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pdf_renderer-Swift.h"
#endif

@implementation NativePdfRendererPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativePdfRendererPlugin registerWithRegistrar:registrar];
}
@end
