// DangleChartView.swift 
// Charts 
// 
// Created by HCC on 2019/6/18. 
//  
//

import Foundation
import CoreGraphics

/// Chart type that draws dangle bar or line.

open class DangleChartView: BarLineChartViewBase, DangleChartDataProvider
{
    public var scatterData: DangleChartData?
    
    internal override func initialize()
    {
        super.initialize()
        
        renderer = DangleChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        self.xAxis.spaceMin = 0.5
        self.xAxis.spaceMax = 0.5
    }
    
    // MARK: - DangleChartDataProvider
    
    open var dangleData: DangleChartData?
    {
        return _data as? DangleChartData
    }
}
