flutter pub run pigeon --input pigeons/message.dart


from="#import <Flutter\/Flutter.h>"
to="#if TARGET_OS_IOS\n#import <Flutter\/Flutter.h>\n#else\n#import <FlutterMacOS\/FlutterMacOS.h>\n#endif"


sed -i '' "s/$from/$to/g" "ios/Classes/messages.m"
