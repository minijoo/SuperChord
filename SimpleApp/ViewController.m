//
//  ViewController.m
//  SimpleApp
//
//  Created by Ming Chow on 2/7/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <AudioToolBox/AudioServices.h>

#import "AppDelegate.h"
#import "ViewController.h"
#import "VariationViewController.h"
#import "SavedProgressionsViewController.h"
#define TV_WIDTH 309
#define TV_HEIGHT 330
#define BOX_HEIGHT 50

@implementation ViewController
@synthesize beatsTableView;
@synthesize instrumentsTableView;
@synthesize metroSwitch;
@synthesize loadButton;
@synthesize popButton, popoverController, detailItem, bvc, ivc, instrumentItem, savedFiles;

@synthesize beatPlayer, feedbackLabel, volumeLabel, chordBankView, seqView, touchView;
@synthesize cChord, cmChord, csChord, csmChord, dChord, dmChord, dsChord, dsmChord, eChord, emChord, fChord, fmChord, fsChord, fsmChord, gChord, gmChord, gsChord, gsmChord, aChord, amChord, bflChord, bflmChord, bChord, bmChord;
@synthesize tapGestureRecognizer, panGestureRecognizerBox, panGestureRecognizerC, panGestureRecognizerCm, panGestureRecognizerCs, panGestureRecognizerCsm, panGestureRecognizerD, panGestureRecognizerDm, panGestureRecognizerDs, panGestureRecognizerDsm, panGestureRecognizerE, panGestureRecognizerEm, panGestureRecognizerF, panGestureRecognizerFm, panGestureRecognizerFs, panGestureRecognizerFsm, panGestureRecognizerG, panGestureRecognizerGm, panGestureRecognizerGs, panGestureRecognizerGsm, panGestureRecognizerA, panGestureRecognizerAm, panGestureRecognizerBfl, panGestureRecognizerBflm, panGestureRecognizerB, panGestureRecognizerBm;
//@synthesize chordBankViewController;

// IBAction is used to allow your methods to be associated with actions in IB
// Moar: http://stackoverflow.com/questions/1643007/iboutlet-and-ibaction

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{ 
    if (buttonIndex == 0) {
        NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
        NSString *title = [[alertView textFieldAtIndex:0] text];
        [savedFiles addObject:title];
        NSString *archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive", title]];
        [NSKeyedArchiver archiveRootObject:[seqView sequence] toFile:archivePath];
        NSLog(@"varitaotin %@", [[[seqView sequence] objectAtIndex:1] variation]);
        NSLog(@"savedFiles contents: %@", savedFiles);
    }
}

-(IBAction)saveTriggered:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Progression Title" message:@"Please enter progression title:" delegate:self cancelButtonTitle:@"Save" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Progression name";
    [alert show];
}

-(IBAction)loadTriggered:(id)sender {
    CGRect rect = loadButton.frame;
    SavedProgressionsViewController *savedProgressions = [[SavedProgressionsViewController alloc] init];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:savedProgressions]; 
    [popover setPopoverContentSize:CGSizeMake(400, 500) animated:YES];
    popover.delegate = self;
    self.popoverController = popover;
    rect.size.width = MIN(rect.size.width, 100); 
    [popover presentPopoverFromRect:rect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)setDetailItem:(id)newDetailItem {
    
        //[detailItem release];
        detailItem = newDetailItem;
        
        //---update the view---
        [seqView changedVariationTo:[detailItem description]];
        //movieSelected.text = [detailItem description];
    
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
    
}

- (void)setInstrumentItem:(id)newInstrumentItem {
    
    if (instrumentItem != newInstrumentItem) {
        //[detailItem release];
        instrumentItem = newInstrumentItem;
        
        //---update the view---
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (instrumentItem == @"Piano")
            appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0xC0, 0, 0);
        else if (instrumentItem == @"Guitar")
            appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0xC0, 25, 0);
    }
}

- (void)setSavedItem:(id)newSavedItem {
    NSLog(@"selected progression title: %@", newSavedItem);
    NSMutableArray *seq;
    NSString *archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive", newSavedItem]];
    seq = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    NSLog(@"sequence retrieved: %@", seq);
    NSLog(@"random variation: %@ and title %@", [[seq objectAtIndex:1] variation], [[seq objectAtIndex:1] title]);
    [seqView loadSequence:seq];
}

- (IBAction)tempoSliderValueChanged:(id)sender
{
    UISlider *slider = (UISlider *) sender;
    int BPM = (int)slider.value;
    SPB = 1.0/(BPM/60.0);
    NSLog(@"Tempo set to %d BPM or %f SPB", BPM, SPB);
}

-(IBAction) showVariations:(id) sender {
    
    UIButton *button = (UIButton *)sender;
    
    VariationViewController *variations = [[VariationViewController alloc] init];
    //[[VariationViewController alloc] initWithNibName:@"VariationViewController" bundle:[NSBundle mainBundle]]; 
        
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:variations]; 
    //set popovercontentsize
    popover.delegate = self;
    
    self.popoverController = popover;
        
    CGRect popoverRect = [button frame];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 100); 
    [popover presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void) playTick:(id) nothing 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x91, 110, 90);
    [self performSelector:@selector(playTick:) withObject:nil afterDelay:SPB];
}

- (IBAction) metroSwitched:(id) sender
{
    NSLog(@"Metro switched");
    if(metroSwitch.on) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x91, 110, 90);
        [self performSelector:@selector(playTick:) withObject:nil afterDelay:SPB];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (IBAction) buttonDragged:(id) sender withEvent:(UIEvent *) event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:chordBankView];
    NSLog(@"Dragged to %f and %f", point.x, point.y);
    UIControl *control = sender;
    control.center = point;
}

-(void) stopChord:(NSNumber *)note
{
    [seqView stopChordWithRoot:[note intValue]];
}

-(IBAction)buttonTriggered:(id)sender
{
    UIButton *theButton = (UIButton *)sender;
    NSLog(@"You pressed the button %@", theButton.currentTitle);
    
    if ([theButton.currentTitle isEqualToString:@"C"]) {
        [seqView playChordWithRoot:0 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:0] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"Cm"]) {
        [seqView playChordWithRoot:0 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:0] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"C#"]) {
        [seqView playChordWithRoot:1 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:1] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"C#m"]) {
        [seqView playChordWithRoot:1 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:1] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"D"]) {
        [seqView playChordWithRoot:2 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:2] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"Dm"]) {
        [seqView playChordWithRoot:2 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:2] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"D#"]) {
        [seqView playChordWithRoot:3 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:3] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"D#m"]) {
        [seqView playChordWithRoot:3 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:3] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"E"]) {
        [seqView playChordWithRoot:4 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:4] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"Em"]) {
        [seqView playChordWithRoot:4 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:4] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"F"]) {
        [seqView playChordWithRoot:5 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:5] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"Fm"]) {
        [seqView playChordWithRoot:5 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:5] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"F#"]) {
        [seqView playChordWithRoot:6 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:6] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"F#m"]) {
        [seqView playChordWithRoot:6 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:6] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"G"]) {
        [seqView playChordWithRoot:7 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:7] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"Gm"]) {
        [seqView playChordWithRoot:7 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:7] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"G#"]) {
        [seqView playChordWithRoot:8 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:8] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"G#m"]) {
        [seqView playChordWithRoot:8 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:8] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"A"]) {
        [seqView playChordWithRoot:9 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:9] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"Am"]) {
        [seqView playChordWithRoot:9 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:9] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"B♭"]) {
        [seqView playChordWithRoot:10 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:10] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"B♭m"]) {
        [seqView playChordWithRoot:10 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:10] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"B"]) {
        [seqView playChordWithRoot:11 withVariation:@"major"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:11] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"Bm"]) {
        [seqView playChordWithRoot:11 withVariation:@"minor"];
        [self performSelector:@selector(stopChord:) withObject:[NSNumber numberWithInt:11] afterDelay:2.0];
    } else if ([theButton.currentTitle isEqualToString:@"About this App"]) {
        UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"About This App"
                                                      message:@"Version: 1.0\nAuthor: Joo Kang\n"
                                                     delegate:self
                                            cancelButtonTitle:@"Done!"
                                            otherButtonTitles:nil,
                             nil];
        [view show];
    } else if ([theButton.currentTitle isEqualToString:@"Mailmen"]) {
        NSURL* url = [NSURL URLWithString:@"http://itunes.apple.com/us/app/mailmen/id488804738?mt=8"];
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(IBAction)beatButtonTriggered:(id)sender 
{
    NSError *audioError;
    NSURL *urlPathOfAudio;
    urlPathOfAudio = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/rockbeat.mp3", [[NSBundle mainBundle] resourcePath]]];
    beatPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPathOfAudio error:&audioError];
    beatPlayer.numberOfLoops = -1;
    if (beatPlayer != nil) 
        [beatPlayer play];
    else
        NSLog(@"%@", [audioError description]);
}

-(IBAction)stopButtonTriggered:(id)sender
{
    [beatPlayer stop];
}

-(IBAction)sliderChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSString *volumeText = [NSString stringWithFormat:@"%f", slider.value];
    [volumeLabel setText:volumeText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

/* TouchBox behavior */
-(void) handlePansInBox:(UIPanGestureRecognizer *)sender
{
    CGPoint pos = [sender locationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"You are starting at %@", NSStringFromCGPoint(pos));
        currentBox = (pos.y - touchView.frame.origin.y - 10)/BOX_HEIGHT;
        if (currentBox > 6) currentBox = 5;
        if (currentBox < 0) currentBox = 0;
        NSLog(@"Starting in box%d", currentBox);
        box[currentBox] = YES;
        //[seqView moveForward];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        currentBox = (pos.y - touchView.frame.origin.y - 10)/BOX_HEIGHT;
        if (currentBox > 6) currentBox = 5;
        if (currentBox < 0) currentBox = 0;
        NSLog(@"Currently in box%d", currentBox);
        if (box[currentBox] == NO) {
            int oldBox = -1;
            for (int i=0; i<6; i++) {
                if (box[i]) {
                    oldBox=i;
                    break;
                }
            } // oldBox set to previous box number
            NSLog(@"Came from box%d", oldBox);
            box[oldBox] = NO;
            box[currentBox] = YES;
            int ithNote;
            if (oldBox < currentBox ) ithNote = oldBox;
            else if (oldBox > currentBox) ithNote = currentBox;
            if (pos.x - touchView.frame.origin.x < TV_WIDTH*(1.0/2.0)) [seqView ofCurrentChordPlayNote:ithNote];
        }
        /*if (pos.y < touchView.frame.origin.y + TV_HEIGHT/2) 
            exited = YES;
        if (CGRectContainsPoint(CGRectMake(touchView.frame.origin.x, touchView.frame.origin.y + TV_HEIGHT/2,
                                           TV_WIDTH, TV_HEIGHT), pos) && exited) {
            NSLog(@"chaged");
            [seqView stopAllNotes];
            [seqView playCurrentChord];
            exited = NO;
        } */
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [seqView moveForward];
        for (int i=0; i<20; i++) [seqView stopAllNotes];
        for (int i=0; i<6; i++) box[i] = NO;
    }
}

/* Drag and dropping chords from chord bank */
-(void) handlePans:(UIPanGestureRecognizer *)sender
{
    CGPoint pos = [sender locationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"You are starting at %@", NSStringFromCGPoint(pos));
        buttonDragged = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buttonDragged.frame = CGRectMake(pos.x - chordBankView.frame.origin.x - 55, pos.y - chordBankView.frame.origin.y - 25, 110, 50);
        [buttonDragged setTitle: [seqView chordOfTag: [sender view].tag] forState:UIControlStateNormal];
        buttonDragged.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        [chordBankView addSubview:buttonDragged];
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"You moved to %@", NSStringFromCGPoint(pos));  
        NSLog(@"Dragged to %f and %f", pos.x, pos.y);
        UIControl *control = buttonDragged;
        control.center = CGPointMake(pos.x - chordBankView.frame.origin.x, pos.y - chordBankView.frame.origin.y);
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"You stopped at %@", NSStringFromCGPoint(pos));
        if (CGRectContainsPoint(seqView.frame, pos)) {
            NSLog(@"origin is %@", NSStringFromCGRect(seqView.frame));
            NSLog(@"dragged to seqView");
            // Add to sequence here
            [seqView addChord:[sender view].tag];
        } else {
            NSLog(@"drop");
        }
        [buttonDragged removeFromSuperview];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{    
   
    savedFiles = [[NSMutableArray alloc] init];
    
    SPB = 0.5;
    
    bvc = [[BeatViewController alloc] init];
    bvc.tableView = beatsTableView;
    [bvc viewDidLoad];
    
    ivc = [[InstrumentViewController alloc] init];
    ivc.tableView = instrumentsTableView;
    [ivc viewDidLoad];
    
    numTaps = 0; exited = YES; currentBox = -1;
    for (int i=0; i<6; i++) box[i] = NO;
    NSLog(@"loaded");
    [super viewDidLoad];
    [seqView initialize];
    seqView.layer.borderWidth = 3.0f;
    seqView.layer.borderColor = [UIColor greenColor].CGColor;
    touchView.layer.borderWidth = 3.0f;
    touchView.layer.borderColor = [UIColor greenColor].CGColor;
    chordBankView.layer.borderWidth = 3.0f;
    chordBankView.layer.borderColor = [UIColor greenColor].CGColor;
    
    panGestureRecognizerBox = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePansInBox:)];
    [touchView addGestureRecognizer:panGestureRecognizerBox];
    
    cChord.tag = 0;
    cmChord.tag = 1;
    csChord.tag = 2;
    csmChord.tag = 3;
    dChord.tag = 4;
    dmChord.tag = 5;
    dsChord.tag = 6;
    dsmChord.tag = 7;
    eChord.tag = 8;
    emChord.tag = 9;
    fChord.tag = 10;
    fmChord.tag = 11;
    fsChord.tag = 12;
    fsmChord.tag = 13;
    gChord.tag = 14;
    gmChord.tag = 15;
    gsChord.tag = 16;
    gsmChord.tag = 17;
    aChord.tag = 18;
    amChord.tag = 19;
    bflChord.tag = 20;
    bflmChord.tag = 21;
    bChord.tag = 22;
    bmChord.tag = 23;
    
    panGestureRecognizerC = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [cChord addGestureRecognizer:panGestureRecognizerC];
    panGestureRecognizerCm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [cmChord addGestureRecognizer:panGestureRecognizerCm];
    panGestureRecognizerCs = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [csChord addGestureRecognizer:panGestureRecognizerCs];
    panGestureRecognizerCsm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [csmChord addGestureRecognizer:panGestureRecognizerCsm];
    panGestureRecognizerD = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [dChord addGestureRecognizer:panGestureRecognizerD];
    panGestureRecognizerDm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [dmChord addGestureRecognizer:panGestureRecognizerDm];
    panGestureRecognizerDs = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [dsChord addGestureRecognizer:panGestureRecognizerDs];
    panGestureRecognizerDsm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [dsmChord addGestureRecognizer:panGestureRecognizerDsm];
    panGestureRecognizerE = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [eChord addGestureRecognizer:panGestureRecognizerE];
    panGestureRecognizerEm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [emChord addGestureRecognizer:panGestureRecognizerEm];
    panGestureRecognizerF = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [fChord addGestureRecognizer:panGestureRecognizerF];
    panGestureRecognizerFm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [fmChord addGestureRecognizer:panGestureRecognizerFm];
    panGestureRecognizerFs = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [fsChord addGestureRecognizer:panGestureRecognizerFs];
    panGestureRecognizerFsm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [fsmChord addGestureRecognizer:panGestureRecognizerFsm];
    panGestureRecognizerG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [gChord addGestureRecognizer:panGestureRecognizerG];
    panGestureRecognizerGm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [gmChord addGestureRecognizer:panGestureRecognizerGm];
    panGestureRecognizerGs = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [gsChord addGestureRecognizer:panGestureRecognizerGs];
    panGestureRecognizerGsm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [gsmChord addGestureRecognizer:panGestureRecognizerGsm];
    panGestureRecognizerA = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [aChord addGestureRecognizer:panGestureRecognizerA];
    panGestureRecognizerAm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [amChord addGestureRecognizer:panGestureRecognizerAm];
    panGestureRecognizerBfl = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [bflChord addGestureRecognizer:panGestureRecognizerBfl];
    panGestureRecognizerBflm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [bflmChord addGestureRecognizer:panGestureRecognizerBflm];
    panGestureRecognizerB = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [bChord addGestureRecognizer:panGestureRecognizerB];
    panGestureRecognizerBm = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePans:)];
    [bmChord addGestureRecognizer:panGestureRecognizerBm];

}

- (void)viewDidUnload
{
    //[self setPopOver:nil];
    [self setBeatsTableView:nil];
    [self setInstrumentsTableView:nil];
    [self setMetroSwitch:nil];
    [self setLoadButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientation
    return YES;
}

@end
