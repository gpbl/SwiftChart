SwiftChart
===========

[![Version](https://img.shields.io/cocoapods/v/SwiftChart.svg?style=flat)](http://cocoapods.org/pods/SwiftChart)
[![License](https://img.shields.io/cocoapods/l/SwiftChart.svg?style=flat)](http://cocoapods.org/pods/SwiftChart)
[![Platform](https://img.shields.io/cocoapods/p/SwiftChart.svg?style=flat)](http://cocoapods.org/pods/SwiftChart)

A simple line / area charting library for iOS, written in Swift.

📈 Line and area charts  
🌞 Multiple series  
🌒 Partially filled series  
🏊 Works with signed Double  
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

- the [Chart](Source/Chart.swift#L40) main class, to initialize and configure the chart’s content, e.g. for adding series or setting up the its appearance
- the [ChartSeries](Source/ChartSeries.swift) class, for creating datasets and configure their appearance
- the [ChartDelegate](Source/Chart.swift#L10-L32) protocol, which tells other objects about the chart’s touch events
- the [ChartColor](Source/ChartColors.swift) struct, containing some predefined colors

**Example**

```swift
let chart = Chart()
let series = ChartSeries([0, 6, 2, 8, 4, 7, 3, 10, 8])
series.color = ChartColors.greenColor()
chart.add(series)
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## To initialize a chart

### From the Interface Builder

The chart can be initialized from the Interface Builder. Drag a normal View into a View Controller and assign to it the `Chart` Custom Class from the Identity Inspector.

### Programmatically

To initialize a chart programmatically, use the `Chart(frame: ...)` initializer, which requires a `frame`:

```swift
let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
```

If you prefer to use Autolayout, set the frame to `0` and add the constraints later:

```swift
let chart = Chart(frame: CGRectZero)
// add constraints now
```

## Adding series

Initialize each series before adding them to the chart. To do so, pass an array to initialize a `ChartSeries` object:

```swift
let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
let series = ChartSeries([0, 6.5, 2, 8, 4.1, 7, -3.1, 10, 8])
chart.add(series)
```

**Result:** 

<img width="400" alt="screen shot 2018-01-07 at 10 51 02" src="https://user-images.githubusercontent.com/120693/34648353-b66f352a-f398-11e7-98b9-9d15dcbdd692.png">


As you can see, as default the values on the x-axis are the progressive indexes of the passed array. You can customize those values by passing an array of `(x: Double, y: Double)` tuples to the series initializer:

```swift
let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
// Create a new series specifying x and y values
let data = [
    (x: 0, y: 0),
    (x: 1, y: 3.1),
    (x: 4, y: 2),
    (x: 5, y: 4.2),
    (x: 7, y: 5),
    (x: 9, y: 9),
    (x: 10, y: 8)
]
let series = ChartSeries(data: data)
chart.add(series)
```

**Result:** 

<img width="400" src="https://user-images.githubusercontent.com/120693/34648477-f8a0c48a-f399-11e7-9e36-123171b6413b.png">

### Partially filled series

Use the `chart.xLabels` property to make the x-axis showing more labels than those inferred from the actual data. For example,

```swift
let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
let data = [
    (x: 0, y: 0), 
    (x: 3, y: 2.5), 
    (x: 4, y: 2), 
    (x: 5, y: 2.3), 
    (x: 7, y: 3), 
    (x: 8, y: 2.2), 
    (x: 9, y: 2.5)
]
let series = ChartSeries(data: data)
series.area = true

// Use `xLabels` to add more labels, even if empty
chart.xLabels = [0, 3, 6, 9, 12, 15, 18, 21, 24]

// Format the labels with a unit
chart.xLabelsFormatter = { String(Int(round($1))) + "h" }

chart.add(series)
```

**Result:**

<img width="400" src="https://user-images.githubusercontent.com/120693/34648482-28818ee6-f39a-11e7-99d3-0eb0f1402f73.png">


### Different colors above and below zero

The chart displays the series in different colors when below or above the zero-axis:

```swift
let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
let data: [Double] = [0, -2, -2, 3, -3, 4, 1, 0, -1]
            
let series = ChartSeries(data)
series.area = true

chart.add(series)

// Set minimum and maximum values for y-axis
chart.minY = -7
chart.maxY = 7

// Format y-axis, e.g. with units
chart.yLabelsFormatter = { String(Int($1)) +  "ºC" }
```

**Result:**

<img width="410" src="https://user-images.githubusercontent.com/120693/34648596-3f0538be-f39c-11e7-9cb3-ea06c025b09c.png">

You can customize the zero-axis and the colors with the `colors` options in the `ChartSeries` class.

```swift
series.colors = (
    above: ChartColors.greenColor(), 
    below: ChartColors.yellowColor(), 
    zeroLevel: -1
)
```

**Result:**

<img width="410" src="https://user-images.githubusercontent.com/120693/34648597-3f269158-f39c-11e7-90d3-d3dfb120c95d.png">


### Multiple series

Using the `chart.add(series: ChartSeries)` and `chart.add(series: Array<ChartSeries>)` methods you can add more series. Those will be indentified with a progressive index in the chart’s `series` property.


```swift
let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))

let series1 = ChartSeries([0, 6, 2, 8, 4, 7, 3, 10, 8])
series1.color = ChartColors.yellowColor()
series1.area = true

let series2 = ChartSeries([1, 0, 0.5, 0.2, 0, 1, 0.8, 0.3, 1])
series2.color = ChartColors.redColor()
series2.area = true

// A partially filled series
let series3 = ChartSeries([9, 8, 10, 8.5, 9.5, 10])
series3.color = ChartColors.purpleColor()

chart.add([series1, series2, series3])
```

**Result:**

<img width="412" alt="screen shot 2018-01-07 at 11 06 55" src="https://user-images.githubusercontent.com/120693/34648532-282fcda8-f39b-11e7-93f3-c502329752b5.png">


## Touch events

To make the chart respond to touch events, implement the `ChartDelegate` protocol in your class, e.g. a View Controller, and then set the chart’s `delegate` property:

```swift
class MyViewController: UIViewController, ChartDelegate {
    override func viewDidLoad() {
        let chart = Chart(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        chart.delegate = self
    }
    
    // Chart delegate
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        // Do something on touch
    }
    
    func didFinishTouchingChart(chart: Chart) {
        // Do something when finished
    }

    func didEndTouchingChart(chart: Chart) {
        // Do something when ending touching chart
    }
}
```

The `didTouchChart` method passes an array of indexes, one for each series, with an optional `Int` referring to the data’s index:

```swift
 func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        for (serieIndex, dataIndex) in enumerate(indexes) {
            if dataIndex != nil {
                // The series at serieIndex has been touched
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex)
            }
        }
    }
```

You can use `chart.valueForSeries()` to access the value for the touched position.

The `x: Double` argument refers to the value on the x-axis: it is inferred from the horizontal position of the touch event, and may be not part of the series values.

The `left: CGFloat` is the x position on the chart’s view, starting from the left side. It may be used to set the  position for a label moving above the chart: 

<img src="https://cloud.githubusercontent.com/assets/120693/11602678/660d660e-9adc-11e5-8a67-0c3036c20862.gif" height="200">

## Common issues and solutions

If you have issue with this library, please tag your question with `swiftchart` on [Stack Overflow](http://stackoverflow.com/tags/swiftcharts/info).

### The chart is not showing

The `Chart` class inherits from `UIView`, so if your chart is not displaying it is likely a problem related to the view's size. Check your view constraints and make sure you initialize it on `viewDidLoad`, when UIKit can calculate the view dimensions.

Some tips for debugging an hidden chart:

* start your app and then debug the UI Hierarchy from the Debug navigator
* initialize a simple UIView with a colored background instead of the chart to easily see how the view is positioned
* try to not to nest the chart in a subview for better debugging

## `Chart` class

### `Chart` options

* `areaAlphaComponent` – alpha factor for the area’s color.
* `axesColor` – the axes’ color.
* `bottomInset` – height of the area at the bottom of the chart, containing the labels for the x-axis.
* `delegate` – the delegate for listening to touch events.
* `highlightLineColor` – color of the highlight line.
* `highlightLineWidth` – width of the highlight line.
* `hideHighlightLineOnTouchEnd` (default `false`) – hide the highlight line when the touch event ends (e.g. when stop swiping over the chart).
* `gridColor` – the grid color.
* `labelColor` – the color of the labels.
* `labelFont` – the font used for the labels.
* `lineWidth` – width of the chart’s lines.
* `maxX` – custom maximum x-value.
* `maxY` – custom maximum y-value.
* `minX` – minimum x-value.
* `minY` – minimum y-value.
* `topInset` – height of the area at the top of the chart, acting a padding to make place for the top y-axis label.
* `xLabelsFormatter` – formats the labels on the x-axis.
* `xLabelsOrientation` – sets the x-axis labels orientation to vertical or horizontal.
* `xLabelsTextAlignment` – text-alignment for the x-labels.
* `xLabelsSkipLast` (default `true`) - Skip the last x-label. Setting this to `false` will make the label overflow the frame width, so use carefully!
* `yLabelsFormatter` – formats the labels on the y-axis.
* `yLabelsOnRightSide` – place the y-labels on the right side.

### Methods

* `add(series: ChartSeries)` – add a series to the chart.
* `removeSeries()` – remove all the series from the chart.
* `removeSeriesAtIndex(index: Int)` – remove a series at the specified index. 
* `valueForSeries()` – get the value of the specified series at the specified index.

## `ChartSeries` class

* `area` – draws an area below the series’ line.
* `line` – set it to `false` to hide the line (useful for drawing only the area).
* `color` – the series color.
* `colors` – a tuple to specify the color above or below the zero (or another value). 
    
  For example, to use red for values above `-4`, and blue for values below `-4`. 
  ```swift
  series.colors = (
      above: ChartColors.redColor(), 
      below: ChartColors.blueColor(), 
      zeroLevel: -4
  )
  ```` 
  

## `ChartDelegate`

* `didTouchChart` – tells the delegate that the specified chart has been touched.
* `didFinishTouchingChart` – tells the delegate that the user finished touching the chart. The user will "finish" touching the chart only swiping left/right outside the chart.
* `didEndTouchingChart` – tells the delegate that the user ended touching the chart. The user will "end" touching the chart whenever the touchesDidEnd method is being called. 

---

## License

SwiftChart is available under the MIT license. See the LICENSE file for more info.
