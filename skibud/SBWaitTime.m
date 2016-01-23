//
//  SBWaitTime.m
//  skibud
//
//  Created by Charley Robinson on 1/17/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import "SBWaitTime.h"

@implementation SBWaitTime {
    NSString* _chairName;
    NSNumber* _waitTimeMinutes;
    BOOL _hasWaitTime;
    NSString* _displayWaitString;
    NSString* _groomingArea;
    NSString* _locationID;
}

@synthesize chairName = _chairName;
@synthesize waitTimeMinutes = _waitTimeMinutes;
@synthesize hasWaitTime = _hasWaitTime;
@synthesize displayWaitString = _displayWaitString;
@synthesize groomingArea = _groomingArea;
@synthesize locationID = _locationID;

- (instancetype)initWithGroomingArea:(NSString*)groomingArea
                          dictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        _groomingArea = groomingArea;
        _chairName = [dictionary valueForKey:@"Name"];
        _hasWaitTime = [dictionary valueForKey:@"HasWaitTime"];
        if (_hasWaitTime) {
            _waitTimeMinutes = [dictionary valueForKey:@"WaitTimeInMinutes"];
        }
        if ((id)[NSNull null] == _waitTimeMinutes) {
            _waitTimeMinutes = nil;
        }
        _displayWaitString = [dictionary valueForKey:@"DisplayForWaitTime"];
        _locationID = [dictionary valueForKey:@"LocationId"];
    }
    return self;
}

+ (NSString*)preprocessChairNameForSpeech:(NSString*)chair {
    chair = [chair lowercaseString];
    chair = [chair stringByReplacingOccurrencesOfString:@"superchair" withString:@"super chair"];
    chair = [chair stringByReplacingOccurrencesOfString:@"superconnect" withString:@"super connect"];
    return chair;
}

- (NSString*)speechString
{
    if (_hasWaitTime && _waitTimeMinutes.floatValue > 0) {
        return [NSString stringWithFormat:@"%@, %@ minutes",
                _chairName, _waitTimeMinutes];
    } else if ([@"Closed" isEqualToString:_displayWaitString]) {
        return [NSString stringWithFormat:@"%@ is closed", _chairName];
    } else {
        return [NSString stringWithFormat:@"%@, no wait", _chairName];
    }
}

@end

