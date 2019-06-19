// DangleChartDataProvider.swift 
// Charts 
// 
// Created by HCC on 2019/6/18. 
//  
//

import Foundation
import CoreGraphics

@objc
public protocol DangleChartDataProvider: BarLineScatterCandleBubbleChartDataProvider
{
    var dangleData: DangleChartData? { get }
}
