//
//  SBWaitTimeCollection.h
//  skibud
//
//  Created by Charley Robinson on 1/17/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SBWaitTime.h"

@interface SBWaitTimeCollection : NSObject

- (void)saveWaitTime:(SBWaitTime*)waitTime;
- (NSArray*) waitTimesForLocation:(CLLocation*)location;

@end
