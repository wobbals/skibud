//
//  SBAltitudeManager.m
//  skibud
//
//  Created by Charley Robinson on 2/5/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import "SBAltitudeManager.h"
#import "CHDataStructures.h"
#import "SBVoiceFeedback.h"

#import <CoreMotion/CoreMotion.h>

#define ALTITUDE_PROCESSING_INTERVAL_SECONDS 60
#define ALTITUDE_CHANGE_METERS_PER_SECOND_THRESHOLD 1.0

@implementation SBAltitudeManager {
    CMAltimeter* _altimeter;
    __weak id<SBAltitudeManagerDelegate> _delegate;
    
    NSMutableArray* _recentAltitudes;
    NSTimeInterval _lastProcessedTime;
    
    SBVoiceFeedback* _voiceFeedback;

    SBAltitudeState _currentAltitudeState;
}

@synthesize voiceFeedback = _voiceFeedback;

- (instancetype)initWithDelegate:(id<SBAltitudeManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _recentAltitudes =
        [[NSMutableArray alloc]
         initWithCapacity:ALTITUDE_PROCESSING_INTERVAL_SECONDS];
        [self start];
    }
    return self;
}

- (void)stop {
    [_altimeter stopRelativeAltitudeUpdates];
    _altimeter = nil;
}

- (void)start {
    [self setupAltimeter];
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
    [_delegate altitudeUpdated:@"-\n-"];
}

- (void)updateAltitude:(CMAltitudeData*)altitudeData
{
    NSLog(@"altitude %f",
          altitudeData.relativeAltitude.doubleValue);
    [_recentAltitudes addObject:altitudeData];
    // fun fact: CHCircularBuffer is not fixed size, so we need to prune old
    // data manually. TODAY I LEARNED WOW
    while (_recentAltitudes.count > ALTITUDE_PROCESSING_INTERVAL_SECONDS) {
        // I wonder if we're shifting memory for this operation?
        [_recentAltitudes removeObjectAtIndex:0];
    }
    NSTimeInterval measuredTime = [[NSDate new] timeIntervalSinceReferenceDate];
    
    if (measuredTime - _lastProcessedTime >
        ALTITUDE_PROCESSING_INTERVAL_SECONDS)
    {
        _lastProcessedTime = measuredTime;
        [self processAltitudeHistory];
    }
    
    NSString* altitudeFormattedString = [NSString stringWithFormat:@"%f m",
                                  altitudeData.relativeAltitude.floatValue];
    [_delegate altitudeUpdated:altitudeFormattedString];
}

- (void)processAltitudeHistory {
    NSLog(@"processing altitude history. n=%lu", _recentAltitudes.count);
    // 1: Calculate linear regression
    double xbar = 0;
    double ybar = 0;
    double minx = INFINITY;
    double maxx = 0;
    for (CMAltitudeData* data in _recentAltitudes) {
        xbar += data.timestamp;
        if (data.timestamp < minx) {
            minx = data.timestamp;
        }
        if (data.timestamp > maxx) {
            maxx = data.timestamp;
        }
        ybar += data.relativeAltitude.doubleValue;
    }
    xbar /= _recentAltitudes.count;
    ybar /= _recentAltitudes.count;

    double a = 0;
    double b = 0;
    for (CMAltitudeData* data in _recentAltitudes) {
        double x = data.timestamp;
        double y = data.relativeAltitude.doubleValue;
        a += (x - xbar) * (y - ybar);
        b += (x - xbar) * (x - xbar);
    }
    double m = a / b;
    double deltat = maxx - minx;
    NSLog(@"altitude trendline is %f over %f seconds", m, deltat);
    
    // 2: Announce trendline slope to delegate, if changed
    SBAltitudeState newState;
    if (m > ALTITUDE_CHANGE_METERS_PER_SECOND_THRESHOLD) {
        newState = SBAltitudeStateAscending;
    } else if (m < -ALTITUDE_CHANGE_METERS_PER_SECOND_THRESHOLD) {
        newState = SBAltitudeStateDescending;
    } else {
        newState = SBAltitudeStateStable;
    }
    
    if (newState != _currentAltitudeState) {
        _currentAltitudeState = newState;
        [_delegate altitudeStateChanged:_currentAltitudeState];
    }
    
}

@end
