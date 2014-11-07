//
//  GPLineChart.swift
//  GPLineChart
//
//  Created by Giampaolo Bellavite on 28/10/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

typealias GPLineChartDataset = (x: Array<Float>, y: Array<Float>, name: String?)

protocol GPLineChartDelegate {
    func didTouchInsideLineChart(lineChart: GPLineChart, point: CGPoint, axisValues: (x: Float, y: Float), data: Array<(x: Float, y: Float)?>, indexes: Array<Int?>)
    func didTouchOutsideLineChart(lineChart: GPLineChart)
}

@IBDesignable
class GPLineChart: UIControl {
    
    typealias Point = (x: Float, y: Float)
    typealias Line = Array<Point>
    
    // MARK: Configuration
    
    var identifier: String?
    
    /**
    Series of (x: x, y: y) values to display in the chart.
    */
    var series: Array<Line> = []
    /**
    Values to display as labels of the x-axis. If not provided, the chart will use
    values of the first dataset.
    */
    var xLabels: Array<Float>?
    
    /**
    Values to display as labels of the y-axis. If not specified, will display the
    lowest, the middle and the highest values.
    */
    var yLabels: Array<Float>?
    
    /**
    Formatter for the labels on the x-axis.
    */
    var xLabelFormatter: (_: Float) -> String = { "\($0)" }
    
    /**
    Formatter for the labels on the y-axis.
    */
    var yLabelFormatter: (_: Float) -> String = { "\($0)" }
    
    /**
    Font used for the labels.
    */
    var font: UIFont = UIFont.systemFontOfSize(12)
    
    /**
    Color for axes and guides.
    */
    var axisColor: UIColor = UIColor.grayColor()
    
    /**
    Height of the area below the chart, containing the labels for the x-axis.
    */
    var axisInset: CGFloat = 20
    
    /**
    Width of the chart lines.
    */
    var lineWidth: CGFloat = 1
    
    /**
    Fill the area below the lines.
    */
    var area: Bool = true
    
    /**
    Delegate for listening to GPLineChart touch events.
    */
    var delegate: GPLineChartDelegate?
    
    /**
    Custom minimum value for the x-axis.
    */
    var minX: Float?
    
    /**
    Custom minimum value for the y-axis.
    */
    var minY: Float?
    
    /**
    Custom maximum value for the x-axis.
    */
    var maxX: Float?
    
    /**
    Custom maximum value for the y-axis.
    */
    var maxY: Float?
    
    /**
    Colors for each serie
    */
    var colors = [
        (aboveXAxis: GPLineChartColors.greenColor(), belowXAxis: GPLineChartColors.redColor()),
        (aboveXAxis: GPLineChartColors.purpleColor(), belowXAxis: GPLineChartColors.orangeColor())
    ]
    
    /**
    Color for the highlight line
    */
    var highlightLineColor = UIColor.grayColor().CGColor
    
    /**
    Width for the highlight line
    */
    var highlightLineWidth: CGFloat = 0.5
    
    /**
    Negative offset for the highlight line, spans above the chart
    */
    var highlightLineOffset: CGFloat = 0
    
    // MARK: Private variables
    
    private var drawingHeight: CGFloat = 0
    private var drawingWidth: CGFloat = 0
    private var lineLayerStore: Array<CAShapeLayer> = []
    private var highlightShapeLayer: CAShapeLayer?
    private var min: (x: Float, y: Float) = (x: 0, y: 0)
    private var max: (x: Float, y: Float) = (x: 0, y: 0)
    
    // MARK: initializations
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience override init() {
        self.init(frame: CGRectZero)
    }
    
    override func drawRect(rect: CGRect) {
        #if TARGET_INTERFACE_BUILDER
            drawIBPlaceholder()
            #else
            drawChart()
        #endif
    }
    
    func drawIBPlaceholder() {
        let placeholder = UIView(frame: self.frame)
        placeholder.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        let label = UILabel()
        label.text = "Line Chart"
        label.font = UIFont.systemFontOfSize(28)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        label.sizeToFit()
        label.frame.origin.x += frame.width/2 - (label.frame.width / 2)
        label.frame.origin.y += frame.height/2 - (label.frame.height / 2)
        
        placeholder.addSubview(label)
        addSubview(placeholder)
    }
    
    func drawChart() {
        
        drawingHeight = bounds.height - axisInset
        drawingWidth = bounds.width
        
        let minMax = getMinMax()
        min = minMax.min
        max = minMax.max
        
        self.highlightShapeLayer = nil
        
        // Remove things before drawing, e.g. when changing orientation
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        for layer in lineLayerStore {
            layer.removeFromSuperlayer()
        }
        lineLayerStore.removeAll()
        
        // Draw content
        
        for (index, serie) in enumerate(series) {
            
            // Separate each line in multiple segments over and below the x axis
            var segments = GPLineChart.segmentLine(serie)
            
            // Print negative segments
            for (i, segment) in enumerate(segments) {
                let scaledXValues = scaleValuesOnXAxis( segment.map( { return $0.x } ) )
                let scaledYValues = scaleValuesOnYAxis( segment.map( { return $0.y } ) )
                drawLine(xValues: scaledXValues, yValues: scaledYValues, serieIndex: index)
                if area {
                    drawArea(xValues: scaledXValues, yValues: scaledYValues, serieIndex: index)
                }
            }
        }
        
        drawAxes()
        if xLabels != nil || series.count > 0 {
            drawLabelsOnXAxis()
        }
        if yLabels != nil || series.count > 0 {
            drawLabelsOnYAxis()
        }
        
    }
    
    // MARK: - Scaling
    
    func getMinMax() -> (min: (x: Float, y: Float), max: (x: Float, y: Float)) {
        var min = (x: self.minX, y: self.minY)
        var max = (x: self.maxX, y: self.maxY)
        
        // Check in datasets
        
        for serie in series {
            let xValues =  serie.map( { (point: Point) -> Float in
                return point.x } )
            let yValues =  serie.map( { (point: Point) -> Float in
                return point.y } )
            
            let newMinX = minElement(xValues)
            let newMinY = minElement(yValues)
            let newMaxX = maxElement(xValues)
            let newMaxY = maxElement(yValues)
            
            if min.x == nil || newMinX < min.x! { min.x = newMinX }
            if min.y == nil || newMinY < min.y! { min.y = newMinY }
            if max.x == nil || newMaxX > max.x! { max.x = newMaxX }
            if max.y == nil || newMaxY > max.y! { max.y = newMaxY }
        }
        
        // Check in labels
        
        if xLabels != nil {
            let newMinX = minElement(xLabels!)
            let newMaxX = maxElement(xLabels!)
            if min.x == nil || newMinX < min.x { min.x = newMinX }
            if max.x == nil || newMaxX > max.x { max.x = newMaxX }
        }
        
        if yLabels != nil {
            let newMinY = minElement(yLabels!)
            let newMaxY = maxElement(yLabels!)
            if min.y == nil || newMinY < min.y { min.y = newMinY }
            if max.y == nil || newMaxY > max.y { max.y = newMaxY }
        }
        
        if min.x == nil { min.x = 0 }
        if min.y == nil { min.y = 0 }
        if max.x == nil { max.x = 0 }
        if max.y == nil { max.y = 0 }
        
        return (min: (x: min.x!, y: min.y!), max: (x: max.x!, max.y!))
        
    }
    
    
    func getMaximum() -> (x: Float, y: Float) {
        
        var maxX: Float?, maxY: Float?
        
        if self.maxX != nil {
            maxX = self.maxX
        }
        
        if self.maxY != nil {
            maxY = self.maxY
        }
        
        if maxX != nil && maxY != nil {
            return (x: maxX!, y: maxY!)
        }
        
        // Check data sets
        
        for serie in series {
            let xValues =  serie.map( { (point: Point) -> Float in
                return point.x } )
            let yValues =  serie.map( { (point: Point) -> Float in
                return point.y } )
            let newMaxX = maxElement(xValues)
            let newMaxY = maxElement(yValues)
            
            if maxX == nil || newMaxX > maxX! {
                maxX = newMaxX
            }
            if maxY == nil || newMaxY > maxY! {
                maxY = newMaxY
            }
            
        }
        
        if xLabels != nil {
            let newMaxX = maxElement(xLabels!)
            if maxX == nil || newMaxX > maxX {
                maxX = newMaxX
            }
        }
        
        if yLabels != nil {
            let newMaxY = maxElement(yLabels!)
            if maxY == nil || newMaxY > maxY {
                maxY = newMaxY
            }
        }
        
        return (x: maxX!, y: maxY!)
        
    }
    
    func scaleValuesOnXAxis(values: Array<Float>) -> Array<Float> {
        let width = Float(drawingWidth)
        
        var factor: Float
        if max.x - min.x == 0 { factor = 0 }
        else { factor = width / (max.x - min.x) }
        
        let scaled = values.map { factor * ($0 - self.min.x) }
        return scaled
    }
    
    func scaleValuesOnYAxis(values: Array<Float>) -> Array<Float> {
        
        let height = Float(drawingHeight)
        var factor: Float
        if max.y - min.y == 0 { factor = 0 }
        else { factor = height / (max.y - min.y) }
        
        let scaled = values.map { height - factor * ($0 - self.min.y) }
        return scaled
    }
    
    func scaleValueOnYAxis(value: Float) -> Float {
        
        let height = Float(drawingHeight)
        var factor: Float
        if max.y - min.y == 0 { factor = 0 }
        else { factor = height / (max.y - min.y) }
        
        let scaled = height - factor * (value - min.y)
        return scaled
    }
    
    // MARK: - Drawings
    
    func isVerticalSegmentAboveXAxis(yValues: Array<Float>) -> Bool {
        
        // YValues are "reverted" from top to bottom, so min is actually the maxz
        let min = maxElement(yValues)
        let zero = scaleValueOnYAxis(0)
        
        return min <= zero
        
    }
    
    func drawLine(#xValues: Array<Float>, yValues: Array<Float>, serieIndex: Int) -> CAShapeLayer {
        
        let isAboveXAxis = isVerticalSegmentAboveXAxis(yValues)
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, CGFloat(xValues.first!), CGFloat(yValues.first!))
        
        for i in 1..<yValues.count {
            let y = yValues[i]
            CGPathAddLineToPoint(path, nil, CGFloat(xValues[i]), CGFloat(y))
        }
        
        var lineLayer = CAShapeLayer()
        lineLayer.frame = self.bounds
        lineLayer.path = path
        if isAboveXAxis {
            lineLayer.strokeColor = colors[serieIndex].aboveXAxis.CGColor
        }
        else {
            lineLayer.strokeColor = colors[serieIndex].belowXAxis.CGColor
        }
        lineLayer.fillColor = nil
        lineLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(lineLayer)
        
        lineLayerStore.append(lineLayer)
        
        return lineLayer
    }
    
    func drawArea(#xValues: Array<Float>, yValues: Array<Float>, serieIndex: Int) {
        let isAboveXAxis = isVerticalSegmentAboveXAxis(yValues)
        let area = CGPathCreateMutable()
        let zero = CGFloat(scaleValueOnYAxis(0))
        
        CGPathMoveToPoint(area, nil, CGFloat(xValues[0]), zero)
        
        for i in 0..<xValues.count {
            CGPathAddLineToPoint(area, nil, CGFloat(xValues[i]), CGFloat(yValues[i]))
        }
        
        CGPathAddLineToPoint(area, nil, CGFloat(xValues.last!), zero)
        
        var areaLayer = CAShapeLayer()
        areaLayer.frame = self.bounds
        areaLayer.path = area
        areaLayer.strokeColor = nil
        if isAboveXAxis {
            areaLayer.fillColor  = colors[serieIndex].aboveXAxis.colorWithAlphaComponent(0.1).CGColor
        }
        else {
            areaLayer.fillColor  = colors[serieIndex].belowXAxis.colorWithAlphaComponent(0.1).CGColor
        }
        areaLayer.lineWidth = 0
        
        self.layer.addSublayer(areaLayer)
        
        lineLayerStore.append(areaLayer)
    }
    
    func drawAxes() {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, axisColor.CGColor)
        CGContextSetLineWidth(context, 0.5)
        
        // xAxis (bottom)
        CGContextMoveToPoint(context, 0, drawingHeight)
        CGContextAddLineToPoint(context, drawingWidth, drawingHeight)
        CGContextStrokePath(context)
        
        // xAxis (top)
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, drawingWidth, 0)
        CGContextStrokePath(context)
        
    }
    
    func drawLabelsOnXAxis() {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, axisColor.colorWithAlphaComponent(0.3).CGColor)
        CGContextSetLineWidth(context, 0.5)
        
        var labels: Array<Float>
        if (xLabels != nil) {
            // Use user-defined labels
            labels = xLabels!
        }
        else {
            // Use labels from the first serie
            labels = series[0].map( { (point: Point) -> Float in
                return point.x } )
        }
        
        let scaled = scaleValuesOnXAxis(labels)
        
        for (i, value) in enumerate(scaled) {
            let x = CGFloat(value)
            
            let label = UILabel(frame: CGRect(x: x, y: drawingHeight, width: 0, height: 0))
            label.font = self.font
            label.text = xLabelFormatter(labels[i])
            
            // Set label size
            label.sizeToFit()
            
            // Center label vertically
            label.frame.origin.y -= (label.frame.height - axisInset) / 2
            
            // Add left padding
            label.frame.origin.x += 5
            
            // Do not add labels outside the frame
            if (label.frame.origin.x) >= drawingWidth {
                continue
            }
            
            self.addSubview(label)
            
            // Add vertical guides
            
            CGContextMoveToPoint(context, x, 0)
            CGContextAddLineToPoint(context, x, self.bounds.height)
            CGContextStrokePath(context)
        }
        
    }
    
    func drawLabelsOnYAxis() {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, axisColor.colorWithAlphaComponent(0.3).CGColor)
        CGContextSetLineWidth(context, 0.5)
        
        var labels: Array<Float>
        if (yLabels != nil) {
            // User-defined labels
            labels = yLabels!
        }
        else {
            // Use y-values
            labels = [min.y, (min.y + max.y) / 2, max.y]
        }
        let scaled = scaleValuesOnYAxis(labels)
        
        for (i, value) in enumerate(scaled) {
            
            let y = CGFloat(value)
            let label = UILabel(frame: CGRect(x: drawingWidth, y: y, width: 0, height: 0))
            label.font = self.font
            label.text = yLabelFormatter(labels[i])
            
            // Set label size
            label.sizeToFit()
            
            
            // If label is on the top part of the chart, put it a bit below
            if Int(y) == 0 {
                label.frame.origin.y += label.frame.height
            }
            
            // Align label to the right with a padding
            label.frame.origin.x -= label.frame.width + 5
            
            // Align label above the value
            label.frame.origin.y -= label.frame.height
            
            self.addSubview(label)
            
            // Do not add line for the label at the bottom
            if (y != drawingHeight) {
                
                CGContextMoveToPoint(context, 0, y)
                CGContextAddLineToPoint(context, self.bounds.width, y)
                CGContextSetLineDash(context, 0, [5], 1)
                CGContextStrokePath(context)
                
            }
        }
        
    }
    
    // MARK: - Touch events
    
    func drawHighlightLineForXValue(x: CGFloat) {
        if let shapeLayer = highlightShapeLayer {
            let path = CGPathCreateMutable()
            
            CGPathMoveToPoint(path, nil, x, 0 - highlightLineOffset)
            CGPathAddLineToPoint(path, nil, x, drawingHeight)
            shapeLayer.path = path
        }
        else {
            let path = CGPathCreateMutable()
            
            CGPathMoveToPoint(path, nil, x, 0)
            CGPathAddLineToPoint(path, nil, x, drawingHeight)
            
            var shapeLayer = CAShapeLayer()
            shapeLayer.frame = self.bounds
            shapeLayer.path = path
            shapeLayer.strokeColor = highlightLineColor
            shapeLayer.fillColor = nil
            shapeLayer.lineWidth = highlightLineWidth
            
            highlightShapeLayer = shapeLayer
            
            self.layer.addSublayer(highlightShapeLayer!)
            lineLayerStore.append(highlightShapeLayer!)
        }
        
    }
    
    func handleTouchEvents(touches: NSSet!, event: UIEvent!) {
        if (series.count == 0) {
            return
        }
        let point: AnyObject! = touches.anyObject()
        let x = point.locationInView(self).x
        let y = point.locationInView(self).y
        let xValue = valueFromPointAtX(x)
        let yValue = valueFromPointAtY(y)
        
        if x < 0 || x > drawingWidth {
            // Remove highlight and end the touch events
            
            if let shapeLayer = highlightShapeLayer {
                shapeLayer.path = nil
            }
            delegate?.didTouchOutsideLineChart(self)
            return
        }
        
        drawHighlightLineForXValue(x)
        
        var touchedIndexes: Array<Int?> = []
        
        for serie in series {
            var touchedIndex: Int? = nil
            let xValues = serie.map( { (point: Point) -> Float in
                return point.x } )
            let closest = GPLineChart.findClosestInValues(xValues, forValue: xValue)
            if closest.lowestIndex != nil && closest.highestIndex != nil {
                // Consider valid only values on the right
                touchedIndex = closest.lowestIndex
            }
            touchedIndexes.append(touchedIndex)
        }
        
        var data: Array<Point?> = []
        for i in 0..<touchedIndexes.count {
            if let valueIndex = touchedIndexes[i] {
                let serie = series[i]
                data.append(serie[valueIndex])
            }
            else {
                data.append(nil)
            }
        }
        
        delegate?.didTouchInsideLineChart(self, point: CGPointMake(x, y), axisValues: (x: xValue, y: yValue), data: data, indexes: touchedIndexes)
        
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        handleTouchEvents(touches, event: event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        handleTouchEvents(touches, event: event)
    }
    
    
    // MARK: - Utilities
    
    func valueFromPointAtX(x: CGFloat) -> Float {
        let value = ((max.x-min.x) / Float(drawingWidth)) * Float(x) + min.x
        return value
    }
    
    func valueFromPointAtY(y: CGFloat) -> Float {
        let value = ((max.y - min.y) / Float(drawingHeight)) * Float(y) + min.y
        return -value
    }
    
    class func findClosestInValues(values: Array<Float>, forValue value: Float) -> (lowestValue: Float?, highestValue: Float?, lowestIndex: Int?, highestIndex: Int?) {
        var lowestValue: Float?, highestValue: Float?, lowestIndex: Int?, highestIndex: Int?
        
        for (i, currentValue) in enumerate(values) {
            if currentValue <= value && (lowestValue == nil || lowestValue! < currentValue) {
                lowestValue = currentValue
                lowestIndex = i
            }
            if currentValue >= value && (highestValue == nil || highestValue! > currentValue) {
                highestValue = currentValue
                highestIndex = i
            }
            
        }
        return (lowestValue: lowestValue, highestValue: highestValue, lowestIndex: lowestIndex, highestIndex: highestIndex)
    }
    
    class func UIColorFromHex(hex: Int) -> UIColor {
        var red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        var green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        var blue = CGFloat((hex & 0xFF)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    class func makeCircleAtLocation(location: CGPoint, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.addArcWithCenter(location, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        return path
    }
    
    /**
    Segment a line in multiple lines when the line touches the x-axis, i.e. separating
    positive from negative values.
    */
    class func segmentLine(line: Line) -> Array<Line> {
        var segments: Array<Line> = []
        var segment: Line = []
        for (i, point) in enumerate(line) {
            segment.append(point)
            if i < line.count - 1 {
                let nextPoint = line[i+1]
                if point.y * nextPoint.y < 0 {
                    // The sign changed, close the segment with the intersection on x-axis
                    let closingPoint = GPLineChart.intersectionOnXAxisBetween(point, and: nextPoint)
                    segment.append(closingPoint)
                    segments.append(segment)
                    // Start a new segment
                    segment = [closingPoint]
                }
            }
            else {
                // End of the line
                segments.append(segment)
            }
        }
        return segments
    }
    
    /**
    Return the intersection of a line between two points on the x-axis
    */
    class func intersectionOnXAxisBetween(p1: Point, and p2: Point) -> Point {
        return (x: p1.x - (p2.x - p1.x) / (p2.y - p1.y) * p1.y, y: 0)
    }
}

struct GPLineChartColors {
    static func blueColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0x1f77b4)
    }
    static func orangeColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0xff7f0e)
    }
    static func greenColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0x2ca02c)
    }
    static func redColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0xd62728)
    }
    static func purpleColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0x9467bd)
    }
    static func maroonColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0x8c564b)
    }
    static func pinkColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0xe377c2)
    }
    static func greyColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0x7f7f7f)
    }
    static func cyanColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0x17becf)
    }
    static func goldColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0xbcbd22)
    }
    static func yellowColor() -> UIColor {
        return GPLineChart.UIColorFromHex(0xe7ba52)
    }
}

