//
//  SBVoiceFeedback.m
//  skibud
//
//  Created by Charley Robinson on 1/17/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import "SBVoiceFeedback.h"
#import "SBWaitTime.h"

#import <AVFoundation/AVFoundation.h>

@implementation SBVoiceFeedback {
    AVSpeechSynthesizer* _synth;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _synth = [[AVSpeechSynthesizer alloc] init];
    }
    return self;
}

- (void)setupAudioSession {
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionAllowBluetooth |
     AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers |
     AVAudioSessionCategoryOptionDuckOthers
                   error:&error];
    if(error) {
        // Do some error handling
    }
    [session setActive:YES error:&error];
    if (error) {
        // Do some error handling
    }
}

- (void)announceTime {
    [self setupAudioSession];
    
    NSDate* now = [NSDate date];
    NSDateFormatter* spokenFormat = [[NSDateFormatter alloc] init];
    [spokenFormat setDateFormat:@"'current time,' h m a"];
    NSString* spokenDateString = [spokenFormat stringFromDate:now];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVSpeechUtterance* phrase =
        [[AVSpeechUtterance alloc] initWithString:spokenDateString];
        [_synth speakUtterance:phrase];
    });

}

- (void)announceWaitTimes:(NSArray*)waitTimes
{
    SBWaitTime* waitTime = [waitTimes objectAtIndex:0];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVSpeechUtterance* phrase =
        [[AVSpeechUtterance alloc] initWithString:waitTime.speechString];
        [_synth speakUtterance:phrase];
    });
}

@end
