//
//  ViewController.m
//  ChartKit
//
//  Created by yxiang on 2017/2/7.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "ViewController.h"
#import "CKHeader.h"

@interface ViewController () <CKSectionProgressDelegate, CKBarViewDataSource, CKBarViewDelegate, CKLineViewDataSource> {
    CKRoundProgress *progress;
    CKLineProgress *lProgress;
    CKSectionProgress *sProgress;
    CKBarView *barView;
    CKLineView *lineView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    progress = [CKRoundProgress roundProgressWithRect:CGRectMake(100, 50, 129.5, 129.5)
                                               colors:@[(__bridge id)[UIColor redColor].CGColor,(__bridge id)[UIColor greenColor].CGColor,(__bridge id)[UIColor yellowColor].CGColor]
                                         gradientType:CKRPGAngle];
    progress.clockwise = YES;
    progress.lineWidth = 5;
    progress.startAngle = -M_PI/2;
    [self.view addSubview:progress];
    [progress addTagert:self forSelector:@selector(progressClick:)];
    progress.subTitleLabel.text = @"购需单处理率";
    progress.titleLabel.format = @"%d";
    progress.titleLabel.util = @"%";
    [progress.titleLabel setNumberStringTo:0 withDuration:0 animation:NO];
    
    lProgress = [CKLineProgress lineProgressWithRect:CGRectMake(100, 190, 200, 10)
                                              colors:@[(__bridge id)[UIColor redColor].CGColor,(__bridge id)[UIColor greenColor].CGColor,(__bridge id)[UIColor yellowColor].CGColor]
                                           lineWidth:5.f];
    [lProgress addTagert:self forSelector:@selector(progressClick:)];
    [self.view addSubview:lProgress];
    
    sProgress = [CKSectionProgress sectionProgressWithRect:CGRectMake(100, 210, 80, 70) colors:@[(__bridge id)[UIColor redColor].CGColor,(__bridge id)[UIColor greenColor].CGColor,(__bridge id)[UIColor yellowColor].CGColor] animationType:CKSPAEach hollowRadius:20];
    sProgress.delegate = self;
    [self.view addSubview:sProgress];
    
    barView = [[CKBarView alloc] initBarViewWithFrame:CGRectMake(20, 300, 300, 160) dataSource:self];
    barView.delegate = self;
    [self.view addSubview:barView];
    
    lineView = [[CKLineView alloc] initWithFrame:CGRectMake(20, 480, 300, 160) dataSource:self];
    lineView.yLabelTitles = @[@"100%",@"80%",@"60%",@"40%",@"20%",@"0%"];
    lineView.isLineRound = YES;
//    lineView.needPoint = NO;
    [self.view addSubview:lineView];
}

- (void)progressClick:(id)sender {
    NSLog(@"%@",sender);
}

- (IBAction)refresh:(id)sender {
    CGFloat percent = (arc4random()%101)/100.f;
    NSTimeInterval duration = progress.duration*ABS(percent-progress.titleLabel.animationEndCountingNumber/100);
    [progress.titleLabel setNumberStringTo:percent*100 withDuration:duration animation:YES];
    [progress setProgress:percent animation:YES];
    [lProgress setProgress:percent animation:YES];
    [sProgress setSectionLocations:@[@0.3,@0.6,@1] animation:YES];
    [barView reloadData];
    [lineView reloadData];
}

#pragma mark - CKBarViewDataSource

- (NSArray *)barViewYaxisTitles:(CKBarView *)aBarView {
    return @[@"100%",@"80%",@"60%",@"40%",@"20%",@"0%"];
}

- (NSInteger)barViewForItemCount:(CKBarView *)aBarView {
    NSInteger count = arc4random()%101;
    return count;
}

- (NSDictionary *)barView:(CKBarView *)aBarView xaxisBarViewInfoForIndex:(NSInteger)index {
    CGFloat percent = (arc4random()%101)/100.f;
    return @{cKBarViewXaxisTitleKey:@"张三",cKBarViewXaxisPercentKey:@(percent)};
}

#pragma mark - CKBarViewDelegate

- (void)barView:(CKBarView *)aBarView didClickedItemForIndex:(NSInteger)index {
    NSLog(@"%ld",index);
}

#pragma mark - CKLineViewDataSource

- (NSInteger)lineViewLineNumbers:(CKLineView *)aLineView {
    return 2;
}

- (NSArray *)lineViewColorsForLine:(CKLineView *)aLineView {
    return @[(__bridge id)[UIColor greenColor].CGColor,(__bridge id)[UIColor redColor].CGColor];
}

- (NSArray *)lineView:(CKLineView *)aLineView percentsForEachLineWithIndex:(NSInteger)index {
    return @[@[@0.9,@0.9,@0.76,@0.54,@0.67,@0.1,@0.79,@0.16,@0.89,@1,@0.99,@0.56],@[@0.3,@0.5,@0.2,@0.4,@0.8,@0.9]][index];
}

- (NSArray *)lineViewXAxisTitle:(CKLineView *)aLineView {
    return @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
}

- (void)lineView:(CKLineView *)aLineView didClickedForLineTag:(NSInteger)tag withPointIndex:(NSInteger)index {
    NSLog(@"%ld   %ld",tag, index);
}

#pragma mark - CKSectionProgressDelegate

- (void)sectionProgress:(CKSectionProgress *)aSectionProgress haveTouchToSectionAreaWithIndex:(NSInteger)index {
    NSLog(@"到第%ld个",index);
}
- (void)sectionProgress:(CKSectionProgress *)aSectionProgress haveLeaveTouchToSectionAreaWithIndex:(NSInteger)index {
    NSLog(@"到第%ld个就结束了",index);
}

@end
