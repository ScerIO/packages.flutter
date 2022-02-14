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

