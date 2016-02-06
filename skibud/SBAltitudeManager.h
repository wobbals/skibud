//
//  SBAltitudeManager.h
//  skibud
//
//  Created by Charley Robinson on 2/5/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBAltitudeManagerDelegate;
@class SBVoiceFeedback;

typedef enum : NSUInteger {
    SBAltitudeStateStable,
    SBAltitudeStateAscending,
    SBAltitudeStateDescending,
} SBAltitudeState;

@interface SBAltitudeManager : NSObject

@property (strong, nonatomic) SBVoiceFeedback* voiceFeedback;

- (instancetype)initWithDelegate:(id<SBAltitudeManagerDelegate>)delegate;

- (void)stop;
- (void)start;

@end

@protocol SBAltitudeManagerDelegate <NSObject>

- (void)altitudeUpdated:(NSString*)altitude;
- (void)altitudeStateChanged:(SBAltitudeState)newState;

@end
