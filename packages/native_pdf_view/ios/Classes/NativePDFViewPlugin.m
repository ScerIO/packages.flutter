#import "NativePDFViewPlugin.h"
#import <native_pdf_view/native_pdf_view-Swift.h>

@implementation NativePDFViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativePDFViewPlugin registerWithRegistrar:registrar];
}
@end
