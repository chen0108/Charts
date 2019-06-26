// DangleChartRenderer.swift 
// Charts 
// 
// Created by HCC on 2019/6/18. 
//  
//

import Foundation
import CoreGraphics

open class DangleChartRenderer: LineScatterCandleRadarRenderer
{
    @objc open weak var dataProvider: DangleChartDataProvider?
    
    @objc public init(dataProvider: DangleChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let dangleData = dataProvider.dangleData
            else {
                return
        }
        
        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()
        
        // Make the chart header the first element in the accessible elements array
        if let chart = dataProvider as? DangleChartView {
            let element = createAccessibleHeader(usingChart: chart,
                                                 andData: dangleData,
                                                 withDefaultDescription: "Dangle Chart")
            accessibleChartElements.append(element)
        }
        
        for set in dangleData.dataSets as! [IDangleChartDataSet] where set.isVisible
        {
            drawDataSet(context: context, dataSet: set)
        }
    }
    
    private var _rangePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _openPoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _closePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _bodyRect = CGRect()
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: IDangleChartDataSet)
    {
        guard
            let dataProvider = dataProvider
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        /// draw body
        if dataSet.isDrawGradientBar == false {
            
            for j in _xBounds
            {
                // get the entry
                guard let e = dataSet.entryForIndex(j) as? DangleChartDataEntry else { continue }
                
                let xPos = e.x
                let high = e.high
                let low = e.low
                
                let doesContainMultipleDataSets = (dataProvider.dangleData?.dataSets.count ?? 1) > 1
                let accessibilityMovementDescription = "draw body"
                var accessibilityRect = CGRect(x: CGFloat(xPos) + 0.5 - barSpace,
                                               y: CGFloat(low * phaseY),
                                               width: (2 * barSpace) - 1.0,
                                               height: (CGFloat(abs(high - low) * phaseY)))
                trans.rectValueToPixel(&accessibilityRect)
                
                // calculate the body
                _bodyRect.origin.x = CGFloat(xPos) - 0.5 + barSpace
                _bodyRect.origin.y = CGFloat(low * phaseY)
                _bodyRect.size.width = (CGFloat(xPos) + 0.5 - barSpace) - _bodyRect.origin.x
                _bodyRect.size.height = CGFloat(high * phaseY) - _bodyRect.origin.y
                
                trans.rectValueToPixel(&_bodyRect)
                
                if dataSet.barAbsoluteWidth > 0 {
                    _bodyRect.origin.x = _bodyRect.origin.x - (dataSet.barAbsoluteWidth - _bodyRect.size.width)/2
                    _bodyRect.size.width = dataSet.barAbsoluteWidth
                }
                
                if _bodyRect.size.height <= 0 {
                    _bodyRect.size.height = 1;
                }
                
                // draw body
                context.saveGState()
                
                let color = dataSet.barColor ?? dataSet.color(atIndex: j)
                context.setFillColor(color.cgColor)
                
                let path: CGMutablePath = CGMutablePath()
                
                if dataSet.isPortSmooth {
                    let radius = _bodyRect.size.width/2
                    
                    let centerTop = CGPoint(x: _bodyRect.origin.x + radius, y: _bodyRect.origin.y)
                    let leftTop = CGPoint(x: _bodyRect.origin.x, y: _bodyRect.origin.y)
                    let rightTop = CGPoint(x: _bodyRect.origin.x + _bodyRect.size.width, y: _bodyRect.origin.y)
                    
                    let centerBom = CGPoint(x: _bodyRect.origin.x + radius, y: _bodyRect.origin.y + _bodyRect.size.height)
                    let leftBom = CGPoint(x: _bodyRect.origin.x, y: _bodyRect.origin.y + _bodyRect.size.height)
                    let rightBom = CGPoint(x: _bodyRect.origin.x + _bodyRect.size.width, y: _bodyRect.origin.y + _bodyRect.size.height)
                    
                    path.move(to: leftTop)
                    path.addLine(to: leftBom)
                    path.addLine(to: rightBom)
                    path.addArc(center: centerBom, radius: radius, startAngle: CGFloat.pi, endAngle: 0, clockwise: true)
                    path.addLine(to: rightTop)
                    path.addArc(center: centerTop, radius: radius, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
                    path.closeSubpath()
                }
                else
                {
                    path.addRect(_bodyRect)
                    path.closeSubpath()
                }
                context.beginPath()
                context.setAlpha(dataSet.barAlpha)
//                context.clip()
                context.addPath(path)
                context.fillPath()
                context.restoreGState()
                
                let axElement = createAccessibleElement(withIndex: j,
                                                        container: dataProvider,
                                                        dataSet: dataSet)
                { (element) in
                    element.accessibilityLabel = "\(doesContainMultipleDataSets ? "\(dataSet.label ?? "Dataset")" : "") " + "\(xPos) - \(accessibilityMovementDescription). low: \(low), high: \(high)"
                    element.accessibilityFrame = accessibilityRect
                }
                
                accessibleChartElements.append(axElement)
            }
        }
        
        // Post this notification to let VoiceOver account for the redrawn frames
        accessibilityPostLayoutChangedNotification()
        
        if dataSet.isDrawGradientBar {
            drawGradientBar(context: context, dataSet: dataSet)
        }
        if dataSet.isDrawBoundaryPointLinkLineEnable {
            drawBoundaryMaxPointLinkLine(context: context, dataSet: dataSet)
            drawBoundaryMinPointLinkLine(context: context, dataSet: dataSet)
        }
        if dataSet.isDrawMainPointLinkLineEnable {
            drawMainPointLinkLine(context: context, dataSet: dataSet)
        }
        if dataSet.isDrawBoundaryPointsEnable {
            drawBoundaryPoint(context: context, dataSet: dataSet)
        }
        if dataSet.isDrawMainPointEnable {
            drawMainPoint(context: context, dataSet: dataSet)
        }
    }
    
    @objc open func drawGradientBar (context: CGContext, dataSet: IDangleChartDataSet)
    {
        guard
            let dataProvider = dataProvider
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        
//        context.saveGState()
        /// draw body
        for j in _xBounds
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? DangleChartDataEntry else { continue }
            
            let xPos = e.x
            let high = e.high
            let low = e.low

            // calculate the body
            _bodyRect.origin.x = CGFloat(xPos) - 0.5 + barSpace
            _bodyRect.origin.y = CGFloat(low * phaseY)
            _bodyRect.size.width = (CGFloat(xPos) + 0.5 - barSpace) - _bodyRect.origin.x
            _bodyRect.size.height = CGFloat(high * phaseY) - _bodyRect.origin.y
            
            trans.rectValueToPixel(&_bodyRect)
            
            if dataSet.barAbsoluteWidth > 0 {
                _bodyRect.origin.x = _bodyRect.origin.x - (dataSet.barAbsoluteWidth - _bodyRect.size.width)/2
                _bodyRect.size.width = dataSet.barAbsoluteWidth
            }
            
            if _bodyRect.size.height <= 0 {
                _bodyRect.size.height = 1;
            }
            // draw gradient bar
            context.saveGState()
            
            let path: CGMutablePath = CGMutablePath()
            if dataSet.isPortSmooth {
                let radius = _bodyRect.size.width/2
                
                let centerTop = CGPoint(x: _bodyRect.origin.x + radius, y: _bodyRect.origin.y)
                let leftTop = CGPoint(x: _bodyRect.origin.x, y: _bodyRect.origin.y)
                let rightTop = CGPoint(x: _bodyRect.origin.x + _bodyRect.size.width, y: _bodyRect.origin.y)

                let centerBom = CGPoint(x: _bodyRect.origin.x + radius, y: _bodyRect.origin.y + _bodyRect.size.height)
                let leftBom = CGPoint(x: _bodyRect.origin.x, y: _bodyRect.origin.y + _bodyRect.size.height)
                let rightBom = CGPoint(x: _bodyRect.origin.x + _bodyRect.size.width, y: _bodyRect.origin.y + _bodyRect.size.height)
        
                path.move(to: leftTop)
                path.addLine(to: leftBom)
                path.addLine(to: rightBom)
                path.addArc(center: centerBom, radius: radius, startAngle: CGFloat.pi, endAngle: 0, clockwise: true)
                path.addLine(to: rightTop)
                path.addArc(center: centerTop, radius: radius, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
                path.closeSubpath()
            }
            else
            {
                path.addRect(_bodyRect)
                path.closeSubpath()
            }
            context.beginPath()
            context.addPath(path)
            context.setAlpha(dataSet.barAlpha)
//            context.clip()
            context.drawLinearGradient(dataSet.barGradient!,
                                       start: CGPoint(x: _bodyRect.origin.x, y: _bodyRect.origin.y),
                                       end: CGPoint(x: _bodyRect.origin.x, y: _bodyRect.origin.y + _bodyRect.size.height),
                                       options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
            
            context.restoreGState()
        }
    }
    
    @objc open func drawBoundaryPoint(context: CGContext, dataSet: IDangleChartDataSet)
    {
        guard
            let dataProvider = dataProvider
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        /// draw boundaryPoint
        for j in _xBounds
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? DangleChartDataEntry else { continue }
            
            let xPos = e.x
            let high = e.high
            let low = e.low
            
            // calculate the body size
            _bodyRect.origin.x = CGFloat(xPos) - 0.5 + barSpace
            _bodyRect.origin.y = CGFloat(low * phaseY)
            _bodyRect.size.width = (CGFloat(xPos) + 0.5 - barSpace) - _bodyRect.origin.x
            _bodyRect.size.height = CGFloat(high * phaseY) - _bodyRect.origin.y
            
            trans.rectValueToPixel(&_bodyRect)
            
            if dataSet.barAbsoluteWidth > 0 {
                _bodyRect.origin.x = _bodyRect.origin.x - (dataSet.barAbsoluteWidth - _bodyRect.size.width)/2
                _bodyRect.size.width = dataSet.barAbsoluteWidth
            }
            
            // draw point
            var radius = dataSet.boundaryPointRadius
            if radius <= 0 {
                radius = _bodyRect.size.width / 2
            }

            let maxPoint = CGPoint(x: _bodyRect.origin.x + _bodyRect.size.width/2, y: _bodyRect.origin.y)
            let maxColor = dataSet.maxPointColor ?? NSUIColor.red
            context.setFillColor(maxColor.cgColor)
            context.fillEllipse(in: CGRect(x: maxPoint.x - radius, y: maxPoint.y - radius, width: radius * 2, height: radius * 2))
            
            let minPoint = CGPoint(x: maxPoint.x, y: _bodyRect.origin.y + _bodyRect.size.height)
            let minColor = dataSet.minPointColor ?? NSUIColor.orange
            context.setFillColor(minColor.cgColor)
            context.fillEllipse(in: CGRect(x: minPoint.x - radius, y: minPoint.y - radius, width: radius * 2, height: radius * 2))
            
        }
        context.restoreGState()
    }
    
    @objc open func drawMainPoint(context: CGContext, dataSet: IDangleChartDataSet)
    {
        guard
            let dataProvider = dataProvider
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        /// draw boundaryPoint
        for j in _xBounds
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? DangleChartDataEntry else { continue }
            let xPos = e.x
            let main = e.main
            
            // calculate the point
            let valueToPixelMatrix = trans.valueToPixelMatrix
            var pt = CGPoint()
            pt.x = CGFloat(e.x)
            pt.y = CGFloat(main * phaseY)
            pt = pt.applying(valueToPixelMatrix)
            
            // calculate the radius
            var radius = dataSet.mainPointRadius
            if radius <= 0 {
                let low = e.low
                let high = e.high
                _bodyRect.origin.x = CGFloat(xPos) - 0.5 + barSpace
                _bodyRect.origin.y = CGFloat(low * phaseY)
                _bodyRect.size.width = (CGFloat(xPos) + 0.5 - barSpace) - _bodyRect.origin.x
                _bodyRect.size.height = CGFloat(high * phaseY) - _bodyRect.origin.y
                
                trans.rectValueToPixel(&_bodyRect)
                if dataSet.barAbsoluteWidth > 0 {
                    _bodyRect.origin.x = _bodyRect.origin.x - (dataSet.barAbsoluteWidth - _bodyRect.size.width)/2
                    _bodyRect.size.width = dataSet.barAbsoluteWidth
                }
                radius = _bodyRect.size.width / 2
            }
        
            let color = dataSet.maxPointColor ?? NSUIColor.blue
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: CGRect(x: pt.x - radius, y: pt.y - radius, width: radius * 2, height: radius * 2))
        }
        context.restoreGState()
    }
    
    @objc open func drawBoundaryMaxPointLinkLine(context: CGContext, dataSet: IDangleChartDataSet)
    {
        guard
            let dataProvider = dataProvider
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        
        context.setLineWidth(dataSet.maxPointLinkLineWidth)
        
        if _lineSegments.count != 2
        {
            // Allocate once in correct size
            _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
        }

        for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? DangleChartDataEntry else { continue }

            _lineSegments[0].x = CGFloat(e.x)
            _lineSegments[0].y = CGFloat(e.high * phaseY)
            
            if j < _xBounds.max
            {
                let next: DangleChartDataEntry? = dataSet.entryForIndex(j + 1) as? DangleChartDataEntry
                if next == nil { break }
                _lineSegments[1] = CGPoint(x: CGFloat(next!.x), y: CGFloat(next!.high * phaseY))
            }
            else
            {
                _lineSegments[1] = _lineSegments[0]
            }
            
            for i in 0..<_lineSegments.count
            {
                _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
            }
            
            if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
            {
                break
            }
            
            // make sure the lines don't do shitty things outside bounds
            if !viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
            {
                continue
            }
            
            // get the color that is set for this line-segment
            let color = dataSet.maxPointLinkLineColor ?? dataSet.color(atIndex: j)
            context.setStrokeColor(color.cgColor)
            context.strokeLineSegments(between: _lineSegments)
        }
        
        context.restoreGState()
    }
    
    @objc open func drawBoundaryMinPointLinkLine(context: CGContext, dataSet: IDangleChartDataSet)
    {
        guard
            let dataProvider = dataProvider
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        
        context.setLineWidth(dataSet.minPointLinkLineWidth)
        
        if _lineSegments.count != 2
        {
            // Allocate once in correct size
            _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
        }
        
        for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? DangleChartDataEntry else { continue }
            
            _lineSegments[0].x = CGFloat(e.x)
            _lineSegments[0].y = CGFloat(e.low * phaseY)
            
            if j < _xBounds.max
            {
                let next: DangleChartDataEntry? = dataSet.entryForIndex(j + 1) as? DangleChartDataEntry
                if next == nil { break }
                _lineSegments[1] = CGPoint(x: CGFloat(next!.x), y: CGFloat(next!.low * phaseY))
            }
            else
            {
                _lineSegments[1] = _lineSegments[0]
            }
            
            for i in 0..<_lineSegments.count
            {
                _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
            }
            
            if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
            {
                break
            }
            
            // make sure the lines don't do shitty things outside bounds
            if !viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
            {
                continue
            }
            
            // get the color that is set for this line-segment
            let color = dataSet.minPointLinkLineColor ?? dataSet.color(atIndex: j)
            context.setStrokeColor(color.cgColor)
            context.strokeLineSegments(between: _lineSegments)
        }
        
        context.restoreGState()
    }
    
    @objc open func drawMainPointLinkLine(context: CGContext, dataSet: IDangleChartDataSet)
    {
        guard
            let dataProvider = dataProvider
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        
        context.setLineWidth(dataSet.mainPointLinkLineWidth)
        
        if _lineSegments.count != 2
        {
            // Allocate once in correct size
            _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
        }
        
        for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? DangleChartDataEntry else { continue }
            
            _lineSegments[0].x = CGFloat(e.x)
            _lineSegments[0].y = CGFloat(e.main * phaseY)
            
            if j < _xBounds.max
            {
                let next: DangleChartDataEntry? = dataSet.entryForIndex(j + 1) as? DangleChartDataEntry
                if next == nil { break }
                _lineSegments[1] = CGPoint(x: CGFloat(next!.x), y: CGFloat(next!.main * phaseY))
            }
            else
            {
                _lineSegments[1] = _lineSegments[0]
            }
            
            for i in 0..<_lineSegments.count
            {
                _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
            }
            
            if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
            {
                break
            }
            
            // make sure the lines don't do shitty things outside bounds
            if !viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
            {
                continue
            }
            
            // get the color that is set for this line-segment
            let color = dataSet.mainPointLinkLineColor ?? dataSet.color(atIndex: j)
            context.setStrokeColor(color.cgColor)
            context.strokeLineSegments(between: _lineSegments)
        }
        
        context.restoreGState()
        }
    
    
    open override func drawValues(context: CGContext)
    {
        
    }
    
    open override func drawExtras(context: CGContext)
    {
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let dangleData = dataProvider.dangleData
            else { return }
        
        context.saveGState()
        
        for high in indices
        {
            guard
                let set = dangleData.getDataSetByIndex(high.dataSetIndex) as? IDangleChartDataSet,
                set.isHighlightEnabled
                else { continue }
            
            guard let e = set.entryForXValue(high.x, closestToY: high.y) as? DangleChartDataEntry else { continue }
            
            if !isInBoundsX(entry: e, dataSet: set)
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let lowValue = e.low * Double(animator.phaseY)
            let highValue = e.high * Double(animator.phaseY)
            var mainValue = e.main * Double(animator.phaseY)
            
            if mainValue == 0 {
                mainValue = (lowValue + highValue) / 2.0
            }
            
            let pt = trans.pixelForValues(x: e.x, y: mainValue)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
            
            // draw xAxis highlight
            if let chart = dataProvider as? DangleChartView {
                let xAxis = chart.xAxis
                drawXAxisHighlight(context: context, point: pt, set: set, entry: e, xAxis: xAxis)
            }
        }
        
        context.restoreGState()
    }
    
    private func createAccessibleElement(withIndex idx: Int,
                                         container: DangleChartDataProvider,
                                         dataSet: IDangleChartDataSet,
                                         modifier: (NSUIAccessibilityElement) -> ()) -> NSUIAccessibilityElement {
        
        let element = NSUIAccessibilityElement(accessibilityContainer: container)
        
        // The modifier allows changing of traits and frame depending on highlight, rotation, etc
        modifier(element)
        
        return element
    }
}
