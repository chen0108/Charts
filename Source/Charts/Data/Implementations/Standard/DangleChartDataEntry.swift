// DangleChartDataEntry.swift 
// Charts 
// 
// Created by HCC on 2019/6/18. 
//  
//

import Foundation

open class DangleChartDataEntry: ChartDataEntry
{
    
    /// high value
    @objc open var high = Double(0.0)
    
    /// low value
    @objc open var low = Double(0.0)
    
    /// main value
    @objc open var main = Double(0.0)
    
    public required init()
    {
        super.init()
    }
    
    @objc public init(x: Double, highValue: Double, lowValue: Double, mainValue: Double)
    {
        super.init(x: x, y: (highValue + lowValue) / 2.0)
        
        self.high = highValue
        self.low = lowValue
        self.main = mainValue
    }
    
    @objc public convenience init(x: Double, highValue: Double, lowValue: Double,  mainValue: Double, icon: NSUIImage?)
    {
        self.init(x: x, highValue: highValue, lowValue: lowValue, mainValue: mainValue)
        self.icon = icon
    }
    
    @objc public convenience init(x: Double, highValue: Double, lowValue: Double, mainValue: Double, data: Any?)
    {
        self.init(x: x, highValue: highValue, lowValue: lowValue, mainValue: mainValue)
        self.data = data
    }
    
    @objc public convenience init(x: Double, highValue: Double, lowValue: Double, mainValue: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, highValue: highValue, lowValue: lowValue, mainValue: mainValue)
        self.icon = icon
        self.data = data
    }

    
    /// The body size (difference between open and mainValue).
    @objc open var bodyRange: Double
    {
        return abs(high - low)
    }
    
    /// the center value of the bar. (Middle value between high and low)
    open override var y: Double
        {
        get
        {
            return super.y
        }
        set
        {
            super.y = (high + low) / 2.0
        }
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! DangleChartDataEntry
        copy.high = high
        copy.low = low
        copy.main = main
        return copy
    }
    
}
