## 2.9.2

* Fixed PdfViewPinch when compiling to WASM [pull#586](https://github.com/ScerIO/packages.flutter/pull/586)

## 2.9.1

* Fixed Android [pull#564](https://github.com/ScerIO/packages.flutter/pull/564)
* Fixed iOS [pull#565](https://github.com/ScerIO/packages.flutter/pull/565)

## 2.9.0

* Implemented document progress feature [pull#537](https://github.com/ScerIO/packages.flutter/pull/537)
* Migrated to SurfaceProducer in PDFX [pull#543](https://github.com/ScerIO/packages.flutter/pull/543)
* Updated Messages.kt [pull#541](https://github.com/ScerIO/packages.flutter/pull/541)
* Removed device_info_plus dependency [pull#544](https://github.com/ScerIO/packages.flutter/pull/544)
* Updated iOS and macOS projects to remove warnings [pull#562](https://github.com/ScerIO/packages.flutter/pull/562)
* Updated device_info_plus version [pull#536](https://github.com/ScerIO/packages.flutter/pull/536)

## 2.8.0

* Added zoom scale customizable [pull#529](https://github.com/ScerIO/packages.flutter/pull/529)
* Fixed web [pull#533](https://github.com/ScerIO/packages.flutter/pull/533)
* Fixed avoid resetting to initialPage each view [pull#530](https://github.com/ScerIO/packages.flutter/pull/530)

## 2.7.0

* Fixed pageSnapping option [pull#435](https://github.com/ScerIO/packages.flutter/pull/435)
* Migrated to package:web [pull#493](https://github.com/ScerIO/packages.flutter/pull/493)
* Bumped device_info_plus dependency to ^10.0.1 [pull#487](https://github.com/ScerIO/packages.flutter/pull/487)
* Adjusted default zoom parameters [pull#487](https://github.com/ScerIO/packages.flutter/pull/487)
* Fixed memory leak (Web) [pull#484](https://github.com/ScerIO/packages.flutter/pull/484)
* Upgrade dependencies

## 2.6.0

* Flutter 3.16 compatibility

## 2.5.0

* Upgrade dependencies

## 2.4.0

* Upgrade dependencies
* Dart 3, Flutter 3.10 compatibility [pull#404](https://github.com/ScerIO/packages.flutter/pull/404)
* Transfer Pdf support check from viewer to renderer [pull#392](https://github.com/ScerIO/packages.flutter/pull/392)
* Added reverse option in `PdfView`  [pull#412](https://github.com/ScerIO/packages.flutter/pull/412)
* Fixup rendering issues in chromium based web-browsers [pull#402](https://github.com/ScerIO/packages.flutter/pull/402)

## 2.3.0

* Added option `forPrint` in image render [pull#301](https://github.com/ScerIO/packages.flutter/pull/301)
* Added password support (web only) [pull#354](https://github.com/ScerIO/packages.flutter/pull/354)
* Updated dependencies

## 2.2.0

* Upgrade dependency `device_info_plus` to v4
* Fixed flutter 3.0 build
* Fixed web install script 
* Fixed some bugs

## 2.1.0

* Update `[photo_view]` dependency to 0.14.0 [pull#306](https://github.com/ScerIO/packages.flutter/pull/306)
* Fixed render crop [pull#305](https://github.com/ScerIO/packages.flutter/pull/305)

## 2.0.1+2

* Fixed broken links at pub.dev
* Fixed readme
* Update pdfjs version in installation script

## 2.0.1+1

* Update readme
## 2.0.1

* Fixed android launch

## 2.0.0

* Provide more docs
* Fixed windows support 
* Added `builders` argument for `PdfViewPinch` & `PdfView`. Example: 
```dart
PdfViewPinch(
  builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
    options: const DefaultBuilderOptions(
      loaderSwitchDuration: const Duration(seconds: 1),
      transitionBuilder: SomeWidget.transitionBuilder,
    ),
    documentLoaderBuilder: (_) =>
        const Center(child: CircularProgressIndicator()),
    pageLoaderBuilder: (_) =>
        const Center(child: CircularProgressIndicator()),
    errorBuilder: (_, error) => Center(child: Text(error.toString())),
    builder: SomeWidget.builder,
  ),
)
```
* Added  widget `PdfPageNumber` for show actual page number & all pages count. Example:
```dart
PdfPageNumber(
  controller: _pdfController,
  // When `loadingState != PdfLoadingState.success`  `pagesCount` equals null_
  builder: (_, state, loadingState, pagesCount) => Container(
    alignment: Alignment.center,
    child: Text(
      '$page/${pagesCount ?? 0}',
      style: const TextStyle(fontSize: 22),
    ),
  ),
)
```
* Added listenable page number `pageListenable` in `PdfController` & `PdfControllerPinch`. Example:
```dart
ValueListenableBuilder<int>(
  valueListenable: controller.pageListenable,
  builder: (context, actualPageNumber, child) => Text(actualPageNumber.toString()),
)
```
* Added listenable loading state `loadingState` in `PdfController` & `PdfControllerPinch`. Example:
```dart
ValueListenableBuilder<PdfLoadingState>(
  valueListenable: controller.loadingState,
  builder: (context, loadingState, loadingState) => (){
    switch (loadingState) {
      case PdfLoadingState.loading:
        return const CircularProgressIndicator();
      case PdfLoadingState.error:
        return  const Text('Pdf load error');
      case PdfLoadingState.success:
        return const Text('Pdf loaded');
    }
  }(),
)
```
* Removed `documentLoader`, `pageLoader`, `errorBuilder`m `loaderSwitchDuration` arguments from `PdfViewPinch` & `PdfView`
* Removed `pageSnapping`, `physics` arguments from `PdfViewPinch`
* Rename `PdfControllerPinch` page control methods like a `PdfController` control names

## 1.0.1+1

* Updated readme

## 1.0.1

* Fixed platforms plugin 

## 1.0.0

* Initial release 

