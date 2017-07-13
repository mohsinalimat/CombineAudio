//
//  ViewController.m
//  CombineAudio
//
//  Created by wos on 13/07/17.
//  Copyright © 2017 Ravi. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#define DIRECTORY_PATH_FILES                                [NSHomeDirectory() stringByAppendingFormat:@"/Documents/"]

@interface ViewController ()
{
    NSMutableArray *arrAudoiCombine;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrAudoiCombine = [[NSMutableArray alloc] initWithObjects:@"cricket",@"cricket",@"cricket",@"cricket", nil];

    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)btnAudioCombine:(id)sender {
    [self combineVoices];
}

#pragma mark - Combine Audio File
- (BOOL) combineVoices {
    
    NSError *error = nil;
    BOOL ok = NO;
    
    CMTime nextClipStartTime = kCMTimeZero;
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    for (int i = 0; i< [arrAudoiCombine count]; i++) {
        NSString *audioFileName = [NSString stringWithFormat:@"%@",[arrAudoiCombine objectAtIndex:i]] ;
        
        //Build the filename with path
        NSString *soundOne = [[NSBundle mainBundle] pathForResource:audioFileName ofType:@"mp3"];
        //NSLog(@"voice file - %@",soundOne);
        
        NSURL *url = [NSURL fileURLWithPath:soundOne];
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
        if ([tracks count] == 0)
            return NO;
        CMTimeRange timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [avAsset duration]);
        AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        ok = [compositionAudioTrack insertTimeRange:timeRangeInAsset  ofTrack:clipAudioTrack atTime:nextClipStartTime error:&error];
        if (!ok) {
            NSLog(@"Current Video Track Error: %@",error);
        }
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
    }
    
    // create the export session
    // no need for a retain here, the session will be retained by the
    // completion handler since it is referenced there
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) return NO;
    
    NSString *soundOneNew = [DIRECTORY_PATH_FILES stringByAppendingPathComponent:@"combined.m4a"];
    //NSLog(@"Output file path - %@",soundOneNew);
    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:soundOneNew]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            NSLog(@"Path : %@",soundOneNew);
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %ld", (long)exportSession.status);
        }
    }];
    
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
