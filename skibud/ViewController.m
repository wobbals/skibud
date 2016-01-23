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
    CMAltimeter* _altimeter;
    CMMotionManager* _motion;
    
    int climbingCounts;
    double lastAltitude;
}

@synthesize waitTimesAnnounceSwitch, masterPowerSwitch, clockAnnounceSwitch;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _voiceFeedback = [[SBVoiceFeedback alloc] init];
    [_voiceFeedback announceTime];
        
    _waitTimeManager = [[SBWaitTimeManager alloc] initWithDelegate:self];
    
    //[self setupAltimeter];
    //[self setupMotion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMotion {
    _motion = [[CMMotionManager alloc] init];
    [_motion setDeviceMotionUpdateInterval:5.0];
    [_motion startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                 withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                                     NSLog(@"motion");
    }];
}

- (void)setupAltimeter {
    if(![CMAltimeter isRelativeAltitudeAvailable]){
        NSLog(@"no altimeter!");
        return;
    }
    _altimeter = [[CMAltimeter alloc] init];
    [_altimeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue]
                                        withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
                                            [self updateAltitude:altitudeData];
                                        }];
    NSLog(@"Started altimeter");
    self.altimeterLabel.text = @"-\n-";
}

- (void)updateAltitude:(CMAltitudeData*)altitudeData
{
    NSString *data = [NSString stringWithFormat:@"%f m",
                      altitudeData.relativeAltitude.floatValue];
    double currentAltitude = altitudeData.relativeAltitude.doubleValue;
    if ((currentAltitude - lastAltitude) > 5) {
        climbingCounts ++;
    } else {
        climbingCounts = 0;
    }
    
    self.altimeterLabel.text = data;
}

#pragma mark UI Events

- (IBAction)masterPower:(id)sender
{
    if (self.masterPowerSwitch.isOn) {
        [_voiceFeedback enable];
    } else {
        [_voiceFeedback shutup];
        [_voiceFeedback disable];
    }
}

- (IBAction)enableWaitTimesAnnounce:(id)sender
{
    if (self.waitTimesAnnounceSwitch.isOn) {
        [_waitTimeManager updateWaitTimes];
    }
}

- (IBAction)enableClockAnnounce:(id)sender
{
    
}


- (void)updatedWaitTimesAvailable
{
    [_voiceFeedback announceWaitTimes:[_waitTimeManager.waitTimes waitTimesForLocation:nil]];
}

@end
