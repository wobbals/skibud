//
//  SBWaitTimeManager.m
//  skibud
//
//  Created by Charley Robinson on 1/17/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import "SBWaitTimeManager.h"

#define WAIT_TIMES_URL @"https://www.epicmix.com/VailResorts/sites/epicmix/api/Time/WaitTimeByResort.ashx?resortID=3"

@implementation SBWaitTimeManager {
    NSURLSessionDataTask* _downloadTask;
    SBWaitTimeCollection* _waitTimes;
    __weak id<SBWaitTimeManagerDelegate> _delegate;
}

@synthesize waitTimes = _waitTimes;
@synthesize delegate = _delegate;

- (instancetype)initWithDelegate:(id<SBWaitTimeManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _waitTimes = [[SBWaitTimeCollection alloc] init];
    }
    return self;
}

- (void)updateWaitTimes {
    NSURL* url = [NSURL URLWithString:WAIT_TIMES_URL];
    NSURLSession *session = [NSURLSession sharedSession];
    _downloadTask = [session dataTaskWithURL:url
                          completionHandler:^(NSData *data,
                                              NSURLResponse *response,
                                              NSError *error) {
                              [self handleDownloadWithData:data
                                                  response:response
                                                     error:error];
                          }];
    [_downloadTask resume];
}

- (void)handleDownloadWithData:(NSData*)data
                      response:(NSURLResponse*)response
                         error:(NSError*)error
{
    NSDictionary* res =
    [NSJSONSerialization JSONObjectWithData:data
                                    options:0
                                      error:nil];
    NSArray* groomingAreas = [res valueForKey:@"GroomingAreas"];
    for (NSDictionary* area in groomingAreas) {
        NSString* groomingAreaName = [area valueForKey:@"Description"];
        NSArray* locations = [area valueForKey:@"Locations"];
        for (NSDictionary* location in locations) {
            SBWaitTime* waitTime =
            [[SBWaitTime alloc] initWithGroomingArea:groomingAreaName
                                          dictionary:location];
            [_waitTimes saveWaitTime:waitTime];
            DDLogDebug(@"%@", [waitTime speechString]);
        }
    }
    [_delegate updatedWaitTimesAvailable];
}

@end
