SwiftChart
===========

[![Version](https://img.shields.io/cocoapods/v/SwiftChart.svg?style=flat)](http://cocoapods.org/pods/SwiftChart)
[![License](https://img.shields.io/cocoapods/l/SwiftChart.svg?style=flat)](http://cocoapods.org/pods/SwiftChart)
[![Platform](https://img.shields.io/cocoapods/p/SwiftChart.svg?style=flat)](http://cocoapods.org/pods/SwiftChart)

A simple line / area charting library for iOS, written in Swift.

📈 Line and area charts  
🌞 Multiple series  
🌒 Partially filled series  
🏊 Works with signed floats  
🖖 Touch events

<p align="center">
<img src="https://cloud.githubusercontent.com/assets/120693/11602670/57ef6b26-9adc-11e5-9f95-b226a2491654.png" height="180"><img src="https://cloud.githubusercontent.com/assets/120693/11602672/5c303ac6-9adc-11e5-9006-3275a16b7ec8.png" height="180">
<img src="https://cloud.githubusercontent.com/assets/120693/11602674/5ed8a808-9adc-11e5-9e30-f55beacf9a94.png" height="180"><img src="https://cloud.githubusercontent.com/assets/120693/11602678/660d660e-9adc-11e5-8a67-0c3036c20862.gif" height="180">
</p>

## Installation

### CocoaPods

SwiftChart is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftChart"
```

### Manually

1. Download **SwiftChart.zip** from the [last release](https://github.com/gpbl/SwiftChart/releases/latest) and extract its content in your project's folder.
2. From the Xcode project, choose *Add Files to <ProjectName>...* from the *File* menu and add the extracted files.

## Usage

The library includes:

- the [Chart](Chart/Chart.swift) main class, to initialize and configure the chart’s content, e.g. for adding series or setting up the its appearance
- the [ChartSeries](Chart/ChartSeries.swift) class, for creating datasets and configure their appearance
- the [ChartDelegate](Chart/Chart.swift) protocol, which tells other objects about the chart’s touch events
- the [ChartColor](Chart/ChartColors.swift) struct, containing some predefined colors

**Example**

```swift
let chart = Chart()
let series = ChartSeries([0, 6, 2, 8, 4, 7, 3, 10, 8])
series.color = ChartColors.greenColor()
chart.addSeries(series)
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.


### To initialize a chart

#### From the Interface Builder

The chart can be initialized from the Interface Builder. Drag a normal View into a View Controller and assign to it the `Chart` Custom Class from the Identity Inspector:
 
![Example](https://cloud.githubusercontent.com/assets/120693/5063826/c01f26d2-6df6-11e4-8122-cb086709d96c.png)

> Parts of the chart’s appearance can be set from the Attribute Inspector.

#### By coding

To initialize a chart programmatically, use the `Chart(frame: ...)` initializer, which requires a `frame`:

```swift
let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
```

If you prefer to use Autolayout, set the frame to `0` and add the constraints later:

```swift
let chart = Chart(frame: CGRectZero)
// add constraints now
```

### Adding series

Initialize each series before adding them to the chart. To do so, pass an array to initialize a `ChartSeries` object:

```swift
let series = ChartSeries([0, 6.5, 2, 8, 4.1, 7, -3.1, 10, 8])
chart.addSeries(series)
```

By default, the values on the x-axis are the progressive indexes of the passed array. You can customize those values by passing an array of `(x: Float, y: Float)` touples to the series’ initializer:

```swift
// Create a new series specifying x and y values
let data = [(x: 0, y: 0), (x: 0.5, y: 3.1), (x: 1.2, y: 2), (x: 2.1, y: -4.2), (x: 2.6, y: 1.1)]
let series = ChartSeries(data)
chart.addSeries(series)
```

#### Multiple series

Using the `chart.addSeries(series: ChartSeries)` and `chart.addSeries(series: Array<ChartSeries>)` methods you can add more series. Those will be indentified with a progressive index in the chart’s `series` property.

## Touch events

To make the chart respond to touch events, implement the `ChartDelegate` protocol in your classes, as a View Controller, and set the chart’s `delegate` property:

```swift
class MyViewController: UIViewController, ChartDelegate {
    override func viewDidLoad() {
        let chart = Chart(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        chart.delegate = self
    }
    
    // Chart delegate
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        // Do something on touch
    }
    
    func didFinishTouchingChart(chart: Chart) {
        // Do something when finished
    }
}
```

The `didTouchChart` method passes an array of indexes, one for each series, with an optional `Int` referring to the data’s index:

```swift
 func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        for (serieIndex, dataIndex) in enumerate(indexes) {
            if dataIndex != nil {
                // The series at serieIndex has been touched
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex)
            }
        }
    }
```

You can use `chart.valueForSeries()` to access the value for the touched position.

The `x: Float` argument refers to the value on the x-axis: it is inferred from the horizontal position of the touch event, and may be not part of the series values.

The `left: CGFloat` is the x position on the chart’s view, starting from the left side. It may be used to set the  position for a label moving above the chart: 

<img src="https://cloud.githubusercontent.com/assets/120693/11602678/660d660e-9adc-11e5-8a67-0c3036c20862.gif" height="200">

## Reference

![reference](https://cloud.githubusercontent.com/assets/120693/5094993/e3a3e10e-6f65-11e4-8619-b7a05d18190e.png)

### Chart class

#### Chart options

* `areaAlphaComponent`: alpha factor for the area’s color.
* `axesColor`: the axes’ color.
* `bottomInset`: height of the area at the bottom of the chart, containing the labels for the x-axis.
* `delegate`: the delegate for listening to touch events.
* `highlightLineColor`: color of the highlight line.
* `highlightLineWidth`: width of the highlight line.
* `gridColor`: the grid color.
* `labelColor`: the color of the labels.
* `labelFont`: the font used for the labels.
* `lineWidth`: width of the chart’s lines.
* `maxX`: custom maximum x-value.
* `maxY`: custom maximum y-value.
* `minX`: minimum x-value.
* `minY`: minimum y-value.
* `topInset`: height of the area at the top of the chart, acting a padding to make place for the top y-axis label.
* `xLabelsFormatter`: formats the labels on the x-axis.
* `xLabelsTextAlignment`: text-alignment for the x-labels.
* `yLabelsFormatter`: formats the labels on the y-axis.
* `yLabelsOnRightSide`: place the y-labels on the right side.

#### Methods

* `addSeries(series: ChartSeries)`: add a series to the chart.
* `removeSeries()`: remove all the series from the chart.
* `removeSeriesAtIndex(index: Int)`: remove a series at the specified index. 
* `valueForSeries()`: get the value of the specified series at the specified index.

### ChartSeries class

* `area`: draws an area below the series’ line.
* `color`: the series color.
* `colors`: a touple to specify the color above or below the zero, e.g. `(above: ChartsColors.redColor(), below: ChartsColors.blueColor())` 
* `line`: set it to false to hide the line (useful for drawing only the area).

## License

SwiftChart is available under the MIT license. See the LICENSE file for more info.
