//
//  ViewController.m
//  skibud
//
//  Created by Charley Robinson on 1/16/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import "ViewController.h"
#import "SBWaitTimeManager.h"
#import "SBVoiceFeedback.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController () <SBWaitTimeManagerDelegate>

@end

@implementation ViewController {
    SBWaitTimeManager* _waitTimeManager;
    SBVoiceFeedback* _voiceFeedback;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _voiceFeedback = [[SBVoiceFeedback alloc] init];
    //[_voiceFeedback announceTime];
        
    _waitTimeManager = [[SBWaitTimeManager alloc] initWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updatedWaitTimesAvailable
{
    [_voiceFeedback announceWaitTimes:[_waitTimeManager.waitTimes waitTimesForLocation:nil]];
}

@end
