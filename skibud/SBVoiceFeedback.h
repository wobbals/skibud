//
//  SBVoiceFeedback.h
//  skibud
//
//  Created by Charley Robinson on 1/17/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBVoiceFeedback : NSObject

- (void)disable;
- (void)enable;
- (void)announceTime;
- (void)announceWaitTimes:(NSArray*)waitTimes;
- (void)say:(NSString*)phrase;

@end
