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
#import "SBAltitudeManager.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()
<SBWaitTimeManagerDelegate, SBAltitudeManagerDelegate,
CLLocationManagerDelegate>

@end

@implementation ViewController {
    SBWaitTimeManager* _waitTimeManager;
    SBVoiceFeedback* _voiceFeedback;
    SBAltitudeManager* _altitudeManager;
    CMMotionManager* _motion;
    CLLocationManager* _location;
    
    void (^_completionHandler)(UIBackgroundFetchResult result);
}

@synthesize waitTimesAnnounceSwitch, masterPowerSwitch, clockAnnounceSwitch;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _voiceFeedback = [[SBVoiceFeedback alloc] init];
    [_voiceFeedback announceTime];
        
    _waitTimeManager = [[SBWaitTimeManager alloc] initWithDelegate:self];
    
    _altitudeManager = [[SBAltitudeManager alloc] initWithDelegate:self];
    [_altitudeManager setVoiceFeedback:_voiceFeedback];
    //[self setupMotion];
    [self setupLocation];
    
    //[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1800];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    DDLogDebug(@"refresh: %lu", [UIApplication sharedApplication].backgroundRefreshStatus);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)periodicUpdate:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    DDLogDebug(@"periodic update!");
    _completionHandler = completionHandler;
    
    if (self.clockAnnounceSwitch.isOn) {
        [_voiceFeedback announceTime];
    }

    if (self.waitTimesAnnounceSwitch.isOn) {
        [_waitTimeManager updateWaitTimes];
    } else if (nil != _completionHandler) {
        _completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)setupLocation {
    _location = [[CLLocationManager alloc] init];
    [_location setDelegate:self];
    DDLogDebug(@"location authorization status: %d", [CLLocationManager authorizationStatus]);
    [_location requestAlwaysAuthorization];
    [_location startMonitoringSignificantLocationChanges];
    DDLogDebug(@"started location");
}

- (void)teardownLocation {
    [_location stopMonitoringSignificantLocationChanges];
    _location = nil;
}

- (void)setupMotion {
        
    _motion = [[CMMotionManager alloc] init];
    [_motion setDeviceMotionUpdateInterval:5.0];
    [_motion startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                 withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                                     DDLogDebug(@"motion");
    }];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    DDLogDebug(@"location authorization status: %d", status);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    DDLogDebug(@"locationManager");
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        DDLogDebug(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
}

#pragma mark UI Events

- (IBAction)masterPower:(id)sender
{
    if (self.masterPowerSwitch.isOn) {
        [_voiceFeedback enable];
        [_altitudeManager start];
        [self setupLocation];
    } else {
        [_voiceFeedback disable];
        [_altitudeManager stop];
        [self teardownLocation];
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
    if (self.clockAnnounceSwitch.isOn) {
        [_voiceFeedback announceTime];
    }
}

- (void)updatedWaitTimesAvailable
{
    [_voiceFeedback announceWaitTimes:[_waitTimeManager.waitTimes waitTimesForLocation:nil]];
    
    if (nil != _completionHandler) {
        void (^localCompletionHanlder)(UIBackgroundFetchResult result) = _completionHandler;
        _completionHandler = nil;
        localCompletionHanlder(UIBackgroundFetchResultNewData);
    }
}

#pragma mark - SBAltitudeManagerDelegate

- (void)altitudeUpdated:(NSString *)altidude {
    self.altimeterLabel.text = altidude;
}

- (void)altitudeStateChanged:(SBAltitudeState)newState {
    DDLogDebug(@"altitudeStateChanged %lu", newState);
    switch (newState) {
        case SBAltitudeStateStable:
            [_voiceFeedback say:@"altitude is stable"];
            break;
        case SBAltitudeStateDescending:
            [_voiceFeedback say:@"altitude is falling"];
            break;
        case SBAltitudeStateAscending:
            [_voiceFeedback say:@"altitude is climbing"];
            [self periodicUpdate:nil];
            break;
            
        default:
            break;
    }
}


@end
