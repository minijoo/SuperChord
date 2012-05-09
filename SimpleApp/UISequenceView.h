//
//  UISequenceView.h
//  SimpleApp
//
//  Created by Music2 on 4/2/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Chord.h"

@interface UISequenceView : UIView
{
    @private
    int currentIndex;
    int longPressedButtonIndex;
}

@property (strong) AVAudioPlayer *player;
@property (nonatomic, retain) NSMutableArray *sequence;
@property (nonatomic, retain) NSMutableArray *sequenceButtons;
@property (nonatomic, retain) UIButton *clearButton;

@property (nonatomic, retain) UIPopoverController *popoverController;

-(void) initialize;
-(void) loadSequence: (NSMutableArray *)seq;
-(NSString *) getTitleOfCurrentChord;
-(IBAction)buttonTapped:(id)sender;
-(void) addChord: (NSInteger)chordTag;
-(void) playCurrentChord;
-(void) ofCurrentChordPlayNote:(int)ith;
-(void) moveForward;
-(void)playChordWithRoot:(unsigned int)root withVariation:(NSString *) var;
-(void)stopChordWithRoot:(unsigned int)root;
-(void)noteOn:(NSNumber *)note;
-(void)noteOff:(NSNumber *)note;
-(void)stopAllNotes;
-(NSString *)chordOfTag:(NSInteger)tag;
-(void)changedVariationTo:(NSString *)variation;

@end
