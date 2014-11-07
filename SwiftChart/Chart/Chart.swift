//
//  Chart.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

protocol ChartDelegate {
    func didTouchInsideChart(chart: Chart, point: CGPoint, axisValues: ChartPoint, data: Array<ChartPoint?>, indexes: Array<Int?>)
    func didTouchOutsideChart(chart: Chart)
}

typealias ChartPoint = (x: Float, y: Float)
typealias ChartLine = Array<ChartPoint>

@IBDesignable
class Chart: UIControl {
    
    // MARK: Configuration
    
    var identifier: String?
    
    /**
    Series of (x: x, y: y) values to display in the chart.
    */
    
    var series: Array<ChartSerie> = []
    
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
    var labelFont: UIFont = UIFont.systemFontOfSize(12)
    
    /**
    Font used for the labels.
    */
    @IBInspectable
    var labelColor: UIColor = UIColor.blackColor()
    
    /**
    Color for axes and guides.
    */
    @IBInspectable
    var axisColor: UIColor = UIColor.grayColor()
    
    /**
    Height of the area below the chart, containing the labels for the x-axis.
    */
    var axisInset: CGFloat = 20
    
    /**
    Width of the chart lines.
    */
    @IBInspectable
    var lineWidth: CGFloat = 1
    
    /**
    Delegate for listening to Chart touch events.
    */
    var delegate: ChartDelegate?
    
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
    Color for the highlight line
    */
    @IBInspectable
    var highlightLineColor = UIColor.grayColor().CGColor
    
    /**
    Width for the highlight line
    */
    @IBInspectable
    var highlightLineWidth: CGFloat = 0.5
    
    /**
    Negative offset for the highlight line, spans above the chart. Useful to display a label on touch.
    */
    var highlightLineOffset: CGFloat = 0
    
    // MARK: Private variables
    
    private var drawingHeight: CGFloat = 0
    private var drawingWidth: CGFloat = 0
    private var lineLayers: Array<CAShapeLayer> = []
    private var highlightShapeLayer: CAShapeLayer?
    private var min: ChartPoint?
    private var max: ChartPoint?
    
    // MARK: initializations
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
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
    
    func addSerie(serie: ChartSerie) {
        series.append(serie)
    }
    
    func addSeries(series: Array<ChartSerie>) {
        for serie in series {
            addSerie(serie)
        }
    }
    
    private func drawIBPlaceholder() {
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
        for layer in lineLayers {
            layer.removeFromSuperlayer()
        }
        lineLayers.removeAll()
        
        // Draw content
        
        for (index, serie) in enumerate(series) {
            
            // Separate each line in multiple segments over and below the x axis
            var segments = Chart.segmentLine(serie.data as ChartLine)
            
            // Print negative segments
            for (i, segment) in enumerate(segments) {
                let scaledXValues = scaleValuesOnXAxis( segment.map( { return $0.x } ) )
                let scaledYValues = scaleValuesOnYAxis( segment.map( { return $0.y } ) )
                if serie.line {
                    drawLine(xValues: scaledXValues, yValues: scaledYValues, serieIndex: index)
                }
                if serie.area {
                    drawArea(xValues: scaledXValues, yValues: scaledYValues, serieIndex: index)
                }
            }
        }
        
        drawAxes()
        if xLabels != nil || series.count > 0 {
            drawLabelsAndGridOnXAxis()
        }
        if yLabels != nil || series.count > 0 {
            drawLabelsAndGridOnYAxis()
        }
        
    }
    
    // MARK: - Scaling
    
    func getMinMax() -> (min: ChartPoint, max: ChartPoint) {
        var min = (x: self.minX, y: self.minY)
        var max = (x: self.maxX, y: self.maxY)
        
        // Check in datasets
        
        for serie in series {
            let xValues =  serie.data.map( { (point: ChartPoint) -> Float in
                return point.x } )
            let yValues =  serie.data.map( { (point: ChartPoint) -> Float in
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
    
    func scaleValuesOnXAxis(values: Array<Float>) -> Array<Float> {
        let width = Float(drawingWidth)
        
        var factor: Float
        if max!.x - min!.x == 0 { factor = 0 }
        else { factor = width / (max!.x - min!.x) }
        
        let scaled = values.map { factor * ($0 - self.min!.x) }
        return scaled
    }
    
    func scaleValuesOnYAxis(values: Array<Float>) -> Array<Float> {
        
        let height = Float(drawingHeight)
        var factor: Float
        if max!.y - min!.y == 0 { factor = 0 }
        else { factor = height / (max!.y - min!.y) }
        
        let scaled = values.map { height - factor * ($0 - self.min!.y) }
        return scaled
    }
    
    func scaleValueOnYAxis(value: Float) -> Float {
        
        let height = Float(drawingHeight)
        var factor: Float
        if max!.y - min!.y == 0 { factor = 0 }
        else { factor = height / (max!.y - min!.y) }
        
        let scaled = height - factor * (value - min!.y)
        return scaled
    }
    
    func getZero() -> Float {
        return scaleValueOnYAxis(0)
    }
    
    // MARK: - Drawings
    
    func isVerticalSegmentAboveXAxis(yValues: Array<Float>) -> Bool {
        
        // YValues are "reverted" from top to bottom, so min is actually the maxz
        let min = maxElement(yValues)
        let zero = getZero()
        
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
            lineLayer.strokeColor = series[serieIndex].colors.above.CGColor
        }
        else {
            lineLayer.strokeColor = series[serieIndex].colors.below.CGColor
        }
        lineLayer.fillColor = nil
        lineLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(lineLayer)
        
        lineLayers.append(lineLayer)
        
        return lineLayer
    }
    
    func drawArea(#xValues: Array<Float>, yValues: Array<Float>, serieIndex: Int) {
        let isAboveXAxis = isVerticalSegmentAboveXAxis(yValues)
        let area = CGPathCreateMutable()
        let zero = CGFloat(getZero())
        
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
            areaLayer.fillColor = series[serieIndex].colors.above.colorWithAlphaComponent(0.1).CGColor
        }
        else {
            areaLayer.fillColor = series[serieIndex].colors.below.colorWithAlphaComponent(0.1).CGColor
        }
        areaLayer.lineWidth = 0
        
        self.layer.addSublayer(areaLayer)
        
        lineLayers.append(areaLayer)
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
    
    func drawLabelsAndGridOnXAxis() {
        
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
            labels = series[0].data.map( { (point: ChartPoint) -> Float in
                return point.x } )
        }
        
        let scaled = scaleValuesOnXAxis(labels)
        
        for (i, value) in enumerate(scaled) {
            let x = CGFloat(value)
            
            let label = UILabel(frame: CGRect(x: x, y: drawingHeight, width: 0, height: 0))
            label.font = labelFont
            label.text = xLabelFormatter(labels[i])
            label.textColor = labelColor
            
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
            
            // Add vertical grid
            
            CGContextMoveToPoint(context, x, 0)
            CGContextAddLineToPoint(context, x, self.bounds.height)
            CGContextStrokePath(context)
        }
        
    }
    
    func drawLabelsAndGridOnYAxis() {
        
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
            labels = [min!.y, (min!.y + max!.y) / 2, max!.y]
        }
        let scaled = scaleValuesOnYAxis(labels)
        
        for (i, value) in enumerate(scaled) {
            
            let y = CGFloat(value)
            let label = UILabel(frame: CGRect(x: drawingWidth, y: y, width: 0, height: 0))
            label.font = labelFont
            label.text = yLabelFormatter(labels[i])
            label.textColor = labelColor
            
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
            
            // Add horizontal grid
            
            if (y != drawingHeight && value != 0) {
                
                CGContextMoveToPoint(context, 0, y)
                CGContextAddLineToPoint(context, self.bounds.width, y)
                CGContextSetLineDash(context, 0, [5], 1)
                CGContextStrokePath(context)
                
            }
        }
        
        UIGraphicsEndImageContext()
        
        // Add grid for zero
        
        if (max!.y > 0) & (min!.y < 0) {
            let zero = CGFloat(getZero())
            CGContextSetStrokeColorWithColor(context, axisColor.colorWithAlphaComponent(0.8).CGColor)
            CGContextMoveToPoint(context, 0, zero)
            CGContextAddLineToPoint(context, self.bounds.width, zero)
            CGContextSetLineDash(context, 0, nil, 0)
            CGContextStrokePath(context)
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
            lineLayers.append(highlightShapeLayer!)
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
        let yValue = valueFromPointAtY(y) + max!.y
        
        if x < 0 || x > drawingWidth {
            // Remove highlight and end the touch events
            
            if let shapeLayer = highlightShapeLayer {
                shapeLayer.path = nil
            }
            delegate?.didTouchOutsideChart(self)
            return
        }
        
        drawHighlightLineForXValue(x)
        
        var touchedIndexes: Array<Int?> = []
        
        for serie in series {
            var touchedIndex: Int? = nil
            let xValues = serie.data.map( { (point: ChartPoint) -> Float in
                return point.x } )
            let closest = Chart.findClosestInValues(xValues, forValue: xValue)
            if closest.lowestIndex != nil && closest.highestIndex != nil {
                // Consider valid only values on the right
                touchedIndex = closest.lowestIndex
            }
            touchedIndexes.append(touchedIndex)
        }
        
        var data: Array<ChartPoint?> = []
        for i in 0..<touchedIndexes.count {
            if let valueIndex = touchedIndexes[i] {
                let serie = series[i]
                data.append(serie.data[valueIndex])
            }
            else {
                data.append(nil)
            }
        }
        
        delegate?.didTouchInsideChart(self, point: CGPointMake(x, y), axisValues: (x: xValue, y: yValue), data: data, indexes: touchedIndexes)
        
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        handleTouchEvents(touches, event: event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        handleTouchEvents(touches, event: event)
    }
    
    
    // MARK: - Utilities
    
    func valueFromPointAtX(x: CGFloat) -> Float {
        let value = ((max!.x-min!.x) / Float(drawingWidth)) * Float(x) + min!.x
        return value
    }
    
    func valueFromPointAtY(y: CGFloat) -> Float {
        let value = ((max!.y - min!.y) / Float(drawingHeight)) * Float(y) + min!.y
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
    
    
    /**
    Segment a line in multiple lines when the line touches the x-axis, i.e. separating
    positive from negative values.
    */
    class func segmentLine(line: ChartLine) -> Array<ChartLine> {
        var segments: Array<ChartLine> = []
        var segment: ChartLine = []
        for (i, point) in enumerate(line) {
            segment.append(point)
            if i < line.count - 1 {
                let nextPoint = line[i+1]
                if point.y * nextPoint.y < 0 || point.y < 0 && nextPoint.y == 0 {
                    // The sign changed, close the segment with the intersection on x-axis
                    let closingPoint = Chart.intersectionOnXAxisBetween(point, and: nextPoint)
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
    class func intersectionOnXAxisBetween(p1: ChartPoint, and p2: ChartPoint) -> ChartPoint {
        return (x: p1.x - (p2.x - p1.x) / (p2.y - p1.y) * p1.y, y: 0)
    }
}


