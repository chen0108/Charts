// DangleChartDataSet.swift 
// Charts 
// 
// Created by HCC on 2019/6/18. 
//  
//

import Foundation

open class DangleChartDataSet: LineScatterCandleRadarChartDataSet,IDangleChartDataSet
{
    public required init()
    {
        super.init()
    }
    
    public override init(entries: [ChartDataEntry]?, label: String?)
    {
        super.init(entries: entries, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    open override func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? CandleChartDataEntry
            else { return }
        
        if e.low < _yMin
        {
            _yMin = e.low
        }
        
        if e.high > _yMax
        {
            _yMax = e.high
        }
        
        calcMinMaxX(entry: e)
    }
    
    open override func calcMinMaxY(entry e: ChartDataEntry)
    {
        guard let e = e as? CandleChartDataEntry
            else { return }
        
        if e.high < _yMin
        {
            _yMin = e.high
        }
        if e.high > _yMax
        {
            _yMax = e.high
        }
        
        if e.low < _yMin
        {
            _yMin = e.low
        }
        if e.low > _yMax
        {
            _yMax = e.low
        }
    }
    
    // MARK: - Styling functions and accessors
    
    /// the space between the candle entries
    ///
    /// **default**: 0.1 (10%)
    private var _barSpace = CGFloat(0.1)
    
    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    open var barSpace: CGFloat
        {
        get
        {
            return _barSpace
        }
        set
        {
            _barSpace = newValue.clamped(to: 0...0.45)
        }
    }
    
    /// if == 0 ,use _barSpace to calculate the appropriate value
    open var barAbsoluteWidth = CGFloat(0.0)
    
    open var barColor: NSUIColor?
    
    open var portSmooth: Bool = false
    
    open var isPortSmooth: Bool { return portSmooth }
    
    open var drawGradientBar: Bool = false
    
    open var isDrawGradientBar: Bool { return drawGradientBar}
    
    open var barGradient: CGGradient?
    
    open var barAlpha = CGFloat(1.0)
    
    /// 边界点
    open var drawBoundaryPointsEnable: Bool = false
    
    open var isDrawBoundaryPointsEnable: Bool { return drawBoundaryPointsEnable }
    
    open var maxPointColor: NSUIColor?
    
    open var minPointColor: NSUIColor?
    
    open var boundaryPointRadius = CGFloat(0.0)
    
    open var drawBoundaryPointLinkLineEnable: Bool = false
    
    open var isDrawBoundaryPointLinkLineEnable: Bool { return drawBoundaryPointLinkLineEnable }
    
    open var maxPointLinkLineColor: NSUIColor?
    
    open var maxPointLinkLineWidth = CGFloat(2)
    
    open var minPointLinkLineColor: NSUIColor?
    
    open var minPointLinkLineWidth = CGFloat(2)
    
    /// 关键点
    open var drawMainPointEnable: Bool = false
    
    open var isDrawMainPointEnable: Bool { return drawMainPointEnable }
    
    open var mainPointColor: NSUIColor?
    
    open var mainPointRadius = CGFloat(0.0)
    
    open var drawMainPointLinkLineEnable: Bool = false
    
    open var isDrawMainPointLinkLineEnable: Bool { return drawMainPointLinkLineEnable }
    
    open var mainPointLinkLineColor: NSUIColor?
    
    open var mainPointLinkLineWidth = CGFloat(2)
    
}
