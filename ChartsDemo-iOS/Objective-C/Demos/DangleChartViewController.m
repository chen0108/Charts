// DangleChartViewController.m 
// ChartsDemo-iOS 
// 
// Created by HCC on 2019/6/18. 
// Copyright © 2019 dcg. All rights reserved. 
//

#import "DangleChartViewController.h"
#import "ChartsDemo_iOS-Swift.h"

@interface DangleChartViewController ()<ChartViewDelegate>

@property (nonatomic, strong) IBOutlet DangleChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;

@end

@implementation DangleChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Dangle Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"portSmooth", @"label": @"toggle PortSmooth"},
                     @{@"key": @"drawBoundaryPointsEnable", @"label": @"drawBoundaryPointsEnable"},
                     @{@"key": @"drawBoundaryPointLinkLineEnable", @"label": @"drawBoundaryPointLinkLineEnable"},
                     @{@"key": @"drawMainPointEnable", @"label": @"drawMainPointEnable"},
                     @{@"key": @"drawMainPointLinkLineEnable", @"label": @"drawMainPointLinkLineEnable"},
                     @{@"key": @"drawGradientBar", @"label": @"drawGradientBar"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];
    
    _chartView.delegate = self;
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.maxVisibleCount = 60;
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    [_chartView setViewPortOffsetsWithLeft:50 top:20 right:20 bottom:30];
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.axisMinimum = 0;
    xAxis.drawGridLinesEnabled = NO;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelCount = 7;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.drawAxisLineEnabled = YES;
    
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.enabled = NO;
    
    _chartView.legend.enabled = NO;
    
    BalloonMarker *marker = [[BalloonMarker alloc]
                             initWithColor: [UIColor colorWithWhite:180/255. alpha:1.0]
                             font: [UIFont systemFontOfSize:12.0]
                             textColor: UIColor.whiteColor
                             insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    marker.chartView = _chartView;
    marker.minimumSize = CGSizeMake(80.f, 40.f);
    _chartView.marker = marker;
    
    _sliderX.value = 20.0;
    _sliderY.value = 100.0;
    [self slidersValueChanged:nil];
}


- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
    [self setDataCount:_sliderX.value + 1 range:_sliderY.value];
}

- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    
    
    self.chartView.xAxis.axisMinimum = 0;
    self.chartView.xAxis.axisMaximum = count;
    
    self.chartView.leftAxis.axisMaximum = 10;
    self.chartView.leftAxis.axisMinimum = 0;
    self.chartView.leftAxis.drawGridLinesEnabled = NO;
    self.chartView.leftAxis.gridColor = UIColor.grayColor;
    [self.chartView.leftAxis setLabelCount:10];
    
    // limit line
    ChartLimitLine *llXAxis = [[ChartLimitLine alloc] initWithLimit:4.5 label:@"Index 10"];
    llXAxis.lineWidth = 3.0;
    llXAxis.xOffset = - 20;
    llXAxis.yOffset = - 15;
    llXAxis.labelPosition = ChartLimitLabelPositionBottomLeft;
    llXAxis.valueFont = [UIFont systemFontOfSize:10.f];
//    [_chartView.leftAxis addLimitLine:llXAxis];
    
    
    for (int i = 1; i < count; i++)
    {
//        double high = (double) (arc4random_uniform(3)) +8;
        double high = 3;
        double low = (double) (arc4random_uniform(3)) + 1;
        double main = (double) (arc4random_uniform(3)) + 4;
        [yVals1 addObject:[[DangleChartDataEntry alloc] initWithX:i highValue:high lowValue:low mainValue:main]];
    }
    
    DangleChartDataSet *set1 = [[DangleChartDataSet alloc] initWithEntries:yVals1 label:@"Data Set"];
    set1.axisDependency = AxisDependencyLeft;
    set1.drawVerticalHighlightIndicatorEnabled = YES;
    [set1 setColor:[UIColor colorWithWhite:80/255.f alpha:1.f]];
    
    set1.drawIconsEnabled = NO;
    set1.barSpace = 0.3;
//    set1.portSmooth = YES;
    set1.drawBoundaryPointsEnable = YES;
    
    NSArray *gradientColors = @[(id)[UIColor blueColor].CGColor,
                                (id)[UIColor greenColor].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    set1.barGradient = gradient;
    set1.barAlpha = 0.5;
    CGGradientRelease(gradient);
    
    DangleChartData *data = [[DangleChartData alloc] initWithDataSet:set1];    
    _chartView.data = data;
}

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"portSmooth"])
    {
        for (id<IDangleChartDataSet> set in _chartView.data.dataSets)
        {
            set.portSmooth = !set.portSmooth;
        }

        [_chartView notifyDataSetChanged];
        return;
    } else if ([key isEqualToString:@"drawBoundaryPointsEnable"])
    {
        for (id<IDangleChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawBoundaryPointsEnable = !set.drawBoundaryPointsEnable;
        }

        [_chartView notifyDataSetChanged];
        return;
    } else if ([key isEqualToString:@"drawBoundaryPointLinkLineEnable"])
    {
        for (id<IDangleChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawBoundaryPointLinkLineEnable = !set.drawBoundaryPointLinkLineEnable;
        }
        
        [_chartView notifyDataSetChanged];
        return;
    } else if ([key isEqualToString:@"drawMainPointEnable"])
    {
        for (id<IDangleChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawMainPointEnable = !set.drawMainPointEnable;
        }
        
        [_chartView notifyDataSetChanged];
        return;
    } else if ([key isEqualToString:@"drawMainPointLinkLineEnable"])
    {
        for (id<IDangleChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawMainPointLinkLineEnable = !set.drawMainPointLinkLineEnable;
        }
        
        [_chartView notifyDataSetChanged];
        return;
    }else if ([key isEqualToString:@"drawGradientBar"])
    {
        for (id<IDangleChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawGradientBar = !set.drawGradientBar;
        }
        
        [_chartView notifyDataSetChanged];
        return;
    }
    
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    _sliderTextX.text = [@((int)_sliderX.value) stringValue];
    _sliderTextY.text = [@((int)_sliderY.value) stringValue];
    
    [self updateChartData];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
