## 3.0.1

* Upgrade `visibility_detector` dependency

## 3.0.0

* Null-safety migration & Flutter v2 capability

## 2.2.0

* Set minimal dart version to 2.8.0

## 2.1.0

* Replaced package `flutter_widgets` to `visibility_detector`
* Set minimal flutter version to 1.17.0

## 2.0.2 

* Fixed show animation for `BouncingScrollPhysics` (scroll under min extend & above max extend)

## 2.0.1 

* Fix missing import for `LiveOptions` ([issue#23](https://github.com/rbcprolabs/packages.flutter/issues/23))

## 2.0.0

* All widgets with pattern `AutoAnimated{List,Grid,SliverList,SliverGrid,IconButton}` renamed to `Live{List,Grid,SliverList,SliverGrid,IconButton}`. For example: `AutoAnimatedList` now named `LiveList`
* `AnimateOnVisibilityWrapper` renamed to `AnimateIfVisibleWrapper` and `AnimateOnVisibilityChange` renamed to `AnimateIfVisible`
* Added `{List,Grid,SliverList,SliverGrid,IconButton}.options` constructors
* Removed `AutoAnimated.separated()` constructor. Now property `separatorBuilder` added in `LiveList()` & `LiveList.options()` constructor and marked as optional
* Added `LiveOptions`
* Added `visibleFraction` as option for `Live{List,Grid,SliverList,SliverGrid,IconButton}` & `LiveOptions`. Animations starts at `double visibleFraction` visible item fraction in sight (default 0.025)
* Docs improvements

## 2.0.0-dev.4

* SliverList & SliverGrid now requires scrollController (From custom `CustomScrollView`). It is necessary in order to find out in which direction the widget scrolls in order to play the animation in the corresponding direction
* `hideWhenGoingBeyond` renamed to `reAnimateOnVisibility` & works with all widgets of the library normally

## 2.0.0-dev.3

* Fixed reanimate on view unmount
* Added `hideWhenGoingBeyond` value Hide the element when it approaches the frame of the screen so that in the future, when it falls into the visibility  range, the animation can be played again. The appearance animation will also play when the item is redrawn. Redrawing is peculiar for all list \ grid views with builder methods

## 2.0.0-dev.2

* Replace list gif in readme

## 2.0.0-dev.1

* Improvement animation algorithm for `AutoAnimatedList`, `AutoAnimatedSliverList`, `AutoAnimatedGrid`, `AutoAnimatedSliverGrid`. 
Now animations start on scroll (element visibility change)

## 1.4.0-dev.1

* Added `AnimateOnVisibilityChange` & `AnimateOnVisibilityWrapper`

## 1.3.0

* Fixed lexical error in `AutoAnimatedIconButton` (`firstToolip` & `secondToolip` renamed to `firstTooltip` & secondTooltip)

## 1.3.0-dev.5

* Fixed error when timer not initialized

## 1.3.0-dev.4

* Fixed items auto additions after animation end

## 1.3.0-dev.3

* Fixed retry animation on items count change
* Marked `itemCount` required 
* Removed deprecated props

## 1.3.0-dev.2

* Added `AutoAnimatedGrid`
* Added `AutoAnimatedSliverGrid`

## 1.3.0-dev.1

* Added `AutoAnimatedSliverList`

## 1.2.3

* Forward animation on items count changed in `AutoAnimatedList`

## 1.2.2 

* Fixed dispose in `AutoAnimatedIconButton`

## 1.2.1

* Fixed auto setting state on rebuild widget for `AutoAnimatedIconButton`

## 1.2.0

* Added constructor `AutoAnimatedIconButton.externalState` with `iconState` property

## 1.1.0

* Added `AutoAnimatedListState.separated`
* Added `AutoAnimatedIconButton`
* Optimized performance


## 1.0.1

* Fixed screenshots paths for pub.dev

## 1.0.0

* Initial release.
