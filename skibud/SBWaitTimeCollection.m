//
//  SBWaitTimeCollection.m
//  skibud
//
//  Created by Charley Robinson on 1/17/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import "SBWaitTimeCollection.h"

@implementation SBWaitTimeCollection {
    NSMutableDictionary* _waitTimes;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _waitTimes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)saveWaitTime:(SBWaitTime*)waitTime
{
    [_waitTimes setObject:waitTime forKey:waitTime.locationID];
}

- (NSArray*) waitTimesForLocation:(CLLocation*)location
{
    return [_waitTimes allValues];
}

@end
