//
//  ViewController.h
//  SimpleApp
//
//  Created by Ming Chow on 2/7/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Chord.h"
#import "UISequenceView.h"
#import "UITouchView.h"
#import "BeatViewController.h"
#import "InstrumentViewController.h"

@interface ViewController : UIViewController
{ 
    
    @private
    int numTaps;
    UIButton *buttonDragged;
    BOOL exited;
    bool box[5];
    int currentBox;
    double SPB;
}

@property (nonatomic, retain) NSMutableArray *savedFiles;
@property (nonatomic, retain) IBOutlet UIButton *popButton;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) id instrumentItem;
@property (nonatomic, retain) id savedItem;
@property (nonatomic, retain) BeatViewController *bvc;
@property (nonatomic, retain) InstrumentViewController *ivc;
@property (weak, nonatomic) IBOutlet UITableView *beatsTableView;
@property (weak, nonatomic) IBOutlet UITableView *instrumentsTableView;
@property (weak, nonatomic) IBOutlet UISwitch *metroSwitch;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;

@property (strong) AVAudioPlayer *beatPlayer;
@property (nonatomic, strong) IBOutlet UILabel *feedbackLabel;
@property (nonatomic, strong) IBOutlet UILabel *volumeLabel;
@property (nonatomic, retain) IBOutlet UIView *chordBankView;
//@property (nonatomic, retain) IBOutlet UIViewController *chordBankViewController;
@property (nonatomic, retain) IBOutlet UISequenceView *seqView;
@property (nonatomic, retain) IBOutlet UITouchView *touchView;
@property (nonatomic, retain) IBOutlet UIButton *cChord;
@property (nonatomic, retain) IBOutlet UIButton *cmChord;
@property (nonatomic, retain) IBOutlet UIButton *csChord;
@property (nonatomic, retain) IBOutlet UIButton *csmChord;
@property (nonatomic, retain) IBOutlet UIButton *dChord;
@property (nonatomic, retain) IBOutlet UIButton *dmChord;
@property (nonatomic, retain) IBOutlet UIButton *dsChord;
@property (nonatomic, retain) IBOutlet UIButton *dsmChord;
@property (nonatomic, retain) IBOutlet UIButton *eChord;
@property (nonatomic, retain) IBOutlet UIButton *emChord;
@property (nonatomic, retain) IBOutlet UIButton *fChord;
@property (nonatomic, retain) IBOutlet UIButton *fmChord;
@property (nonatomic, retain) IBOutlet UIButton *fsChord;
@property (nonatomic, retain) IBOutlet UIButton *fsmChord;
@property (nonatomic, retain) IBOutlet UIButton *gChord;
@property (nonatomic, retain) IBOutlet UIButton *gmChord;
@property (nonatomic, retain) IBOutlet UIButton *gsChord;
@property (nonatomic, retain) IBOutlet UIButton *gsmChord;
@property (nonatomic, retain) IBOutlet UIButton *aChord;
@property (nonatomic, retain) IBOutlet UIButton *amChord;
@property (nonatomic, retain) IBOutlet UIButton *bflChord;
@property (nonatomic, retain) IBOutlet UIButton *bflmChord;
@property (nonatomic, retain) IBOutlet UIButton *bChord;
@property (nonatomic, retain) IBOutlet UIButton *bmChord;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerBox;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerC;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerCm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerCs;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerCsm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerD;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerDm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerDs;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerDsm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerE;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerEm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerF;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerFm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerFs;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerFsm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerG;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerGm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerGs;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerGsm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerA;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerAm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerBfl;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerBflm;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerB;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizerBm;

// IBOutlet is needed to associate properties in your application with components in Interface Builder (IB)
-(IBAction)showVariations:(id)sender;
-(IBAction)metroSwitched:(id)sender;
- (IBAction)tempoSliderValueChanged:(id)sender;
-(IBAction)buttonTriggered:(id)sender;
-(IBAction)sliderChanged:(id)sender;
-(IBAction)beatButtonTriggered:(id)sender;
-(IBAction)stopButtonTriggered:(id)sender;
-(NSString *)chordOfTag:(NSInteger)tag;
-(void)playChordWithRoot:(unsigned int)root withVariation:(NSString *) var;
-(void)noteOn:(NSNumber *)note;
-(void)noteOff:(NSNumber *)note;

@end
