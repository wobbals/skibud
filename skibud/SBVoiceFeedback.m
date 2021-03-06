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

@interface SBVoiceFeedback () <AVSpeechSynthesizerDelegate>

@end

@implementation SBVoiceFeedback {
    AVSpeechSynthesizer* _synth;
    NSMutableArray* _speechQueue;
    BOOL _acceptingSpeech;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _synth = [[AVSpeechSynthesizer alloc] init];
        [_synth setDelegate:self];
        _speechQueue = [NSMutableArray new];
        [self enable];
    }
    return self;
}

- (void)setupAudioSession {
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:
     AVAudioSessionCategoryOptionMixWithOthers |
     AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers |
     AVAudioSessionCategoryOptionDuckOthers
                   error:&error];
    if(error) {
        DDLogDebug(@"Error: setCategory: %@", error);
    }
}

- (void)maybeSpeak {
    // if talking, do nothing
    if (_synth.isSpeaking) {
        return;
    }

    // if nothing to say, stop the audio session
    if (_speechQueue.count <= 0) {
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        return;
    }
    // otherwise, start the audio session and speak
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    
    NSString* speechString = [_speechQueue objectAtIndex:0];
    [_speechQueue removeObjectAtIndex:0];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVSpeechUtterance* phrase =
        [[AVSpeechUtterance alloc] initWithString:speechString];
        [_synth speakUtterance:phrase];
    });
}

- (void)enqueueSpeech:(NSString*)speechString
{
    @synchronized(self) {
        if (!_acceptingSpeech) {
            return;
        }
        [_speechQueue addObject:speechString];
        [self maybeSpeak];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
 didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
 didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    @synchronized(self) {
        [self maybeSpeak];
    }
}

- (void)shutup {
    [_speechQueue removeAllObjects];
    if (_synth.isSpeaking) {
        [_synth stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    } else {
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
    }
}

- (void)disable
{
    @synchronized(self) {
        [self shutup];
        _acceptingSpeech = NO;
    }
}

- (void)enable
{
    @synchronized(self) {
        _acceptingSpeech = YES;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^() {
        [self setupAudioSession];
    });
}

- (void)announceTime {
    NSDate* now = [NSDate date];
    NSDateFormatter* spokenFormat = [[NSDateFormatter alloc] init];
    [spokenFormat setDateFormat:@"'current time,' h"];
    NSString* currentTimeHours = [spokenFormat stringFromDate:now];
    [spokenFormat setDateFormat:@"mm"];
    NSString* minutesPadded = [spokenFormat stringFromDate:now];
    if ('0' == [minutesPadded characterAtIndex:0]) {
        minutesPadded = [NSString stringWithFormat:@"oh %@", minutesPadded];
    }
    [spokenFormat setDateFormat:@"a"];
    NSString* amPm = [spokenFormat stringFromDate:now];
    
    NSString* spokenDateString =
    [NSString stringWithFormat:@"%@ %@ %@",
     currentTimeHours, minutesPadded, amPm];
    
    DDLogDebug(@"%@", spokenDateString);
    [self enqueueSpeech:spokenDateString];

}

- (void)announceWaitTimes:(NSArray*)waitTimes
{
    for (SBWaitTime* waitTime in waitTimes) {
        [self enqueueSpeech:waitTime.speechString];
    }
}

- (void)say:(NSString*)phrase {
    [self enqueueSpeech:phrase];
}

@end
