//
//  SBWaitTimeManager.h
//  skibud
//
//  Created by Charley Robinson on 1/17/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBWaitTime.h"
#import "SBWaitTimeCollection.h"

@protocol SBWaitTimeManagerDelegate <NSObject>

- (void)updatedWaitTimesAvailable;

@end

@interface SBWaitTimeManager : NSObject

@property (nonatomic, weak) id<SBWaitTimeManagerDelegate> delegate;
@property (readonly) SBWaitTimeCollection* waitTimes;

- (instancetype)initWithDelegate:(id<SBWaitTimeManagerDelegate>)delegate;
- (void)updateWaitTimes;

@end
