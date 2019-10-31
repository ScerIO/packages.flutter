#import "NativePDFRendererPlugin.h"
#import <native_pdf_renderer/native_pdf_renderer-Swift.h>

@implementation NativePDFRendererPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativePDFRendererPlugin registerWithRegistrar:registrar];
}
@end
