#if TARGET_OS_IOS
#import <Flutter/Flutter.h>
#else
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@interface PdfxPlugin : NSObject <FlutterPlugin>
@end
