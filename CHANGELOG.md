# Changelog

## [v1.0.0](https://github.com/gpbl/SwiftChart/releases/tag/1.0.0) - 2018-01-07

### Added
- New `hideHighlightLineOnTouchEnd` Chart option
- Initialize a serie with `Int` x-values

### Fixed
- Fixed a crash when using empty series data ([#88](https://github.com/gpbl/SwiftChart/issues/88) by [@trein](https://github.com/trein))

### Changed 
- **(Breaking)** Use `Double` instead of `Float` ([#87](https://github.com/gpbl/SwiftChart/issues/87) by [@trein](https://github.com/trein))

## [v0.5.0](https://github.com/gpbl/SwiftChart/releases/tag/0.5.0) - 2017-05-20

### Added
- New `xLabelsOrientation` option to switch the x-labels orientation between horizontal or vertical ([#61](https://github.com/gpbl/SwiftChart/issues/61))
- New `xLabelsSkipLast` option. Set it to `false` to print the last x-label ([#37](https://github.com/gpbl/SwiftChart/issues/37))

### Changed 
- Automatically redraw the chart when changing series ([#25](https://github.com/gpbl/SwiftChart/issues/25) by [@duemunk](https://github.com/duemunk))
- Update chart on resize ([#24](https://github.com/gpbl/SwiftChart/issues/24) by [@duemunk](https://github.com/duemunk))

## [v0.4.0](https://github.com/gpbl/SwiftChart/releases/tag/0.4.0) - 2016-11-14

### Changed 
- Custom threshold for positive/negative data colors ([#45](https://github.com/gpbl/SwiftChart/issues/45) by [@algrid](https://github.com/algrid))

**This is a potentially breaking change**
If you were setting the `ChartSeries.colors`, you must set the new `zeroLevel` value to `0` to keep the same functionality:

``` diff
- mySeriesl.colors = (above: ChartsColors.redColor(), below: ChartsColors.blueColor())
+ mySeriesl.colors = (above: ChartsColors.redColor(), below: ChartsColors.blueColor(), 0)
```

## [v0.3.0](https://github.com/gpbl/SwiftChart/releases/tag/0.3.0) - 2016-09-26

### Changed 
- **(Breaking)** `addSeries` has been renamed to `add`
- Upgrades the source code and examples to Swift 3

## [v0.2.2](https://github.com/gpbl/SwiftChart/releases/tag/0.2.2) - 2016-07-06

### Fixed 
- Fixed an issue with negative/positive values ([#26](https://github.com/gpbl/SwiftChart/issues/26))

## [v0.2.1](https://github.com/gpbl/SwiftChart/releases/tag/0.2.1) - 2016-02-14

### Added 
- Add the missing public initializer: `Chart(frame: CGFrame)`

## [v0.2.0](https://github.com/gpbl/SwiftChart/releases/tag/0.2.0) - 2015-12-12

### Changed
- Added cocoapods support

## [v0.1.0](https://github.com/gpbl/SwiftChart/releases/tag/0.1.0) - 2014-11-07

First release!
