Color_Off='\033[0m'
Green='\033[0;32m'
BBlue='\033[1;34m'


echo "$BBlue Run pigeon generator$Color_Off"
flutter pub run pigeon --input pigeons/messages.dart
echo "$Green Success$Color_Off"


echo "$BBlue Replace import in generated iOS pigeon file for support macOS$Color_Off"
to="#if TARGET_OS_IOS\n#import <Flutter\/Flutter.h>\n#else\n#import <FlutterMacOS\/FlutterMacOS.h>\n#endif"
from="#import <Flutter\/Flutter.h>"
sed -i "" "s/$from/$to/g" "ios/Classes/messages.m"
echo "$Green Success$Color_Off"


echo "$BBlue Link macOS to iOS (universal) codebase$Color_Off"
sh ./scripts/link_macos.sh
echo "$Green Success$Color_Off"


echo "$BBlue Run objc/java format$Color_Off"
cd ../../
sh ./script/tool_runner.sh format
echo "$Green Success$Color_Off"
