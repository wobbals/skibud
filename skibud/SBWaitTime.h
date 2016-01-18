//
//  SBWaitTime.h
//  skibud
//
//  Created by Charley Robinson on 1/17/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBWaitTime : NSObject

@property (readonly) NSString* locationID;
@property (readonly) NSString* chairName;
@property (readonly) NSNumber* waitTimeMinutes;
@property (readonly) BOOL hasWaitTime;
@property (readonly) NSString* displayWaitString;
@property (readonly) NSString* groomingArea;

- (instancetype)initWithGroomingArea:(NSString*)groomingArea
                          dictionary:(NSDictionary*)dictionary;

- (NSString*)speechString;

@end
