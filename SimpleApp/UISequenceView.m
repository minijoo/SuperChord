//
//  UISequenceView.m
//  SimpleApp
//
//  Created by Music2 on 4/2/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <AudioToolBox/AudioServices.h>

#import "AppDelegate.h"
#import "VariationViewController.h"

#import "UISequenceView.h"
#define V_WIDTH 687
#define V_HEIGHT 330
#define B_WIDTH 75
#define B_HEIGHT 30
#define B_HSPACE 5
#define B_VSPACE 10
#define ORIGIN_X 15
#define ORIGIN_Y 15

static NSString *chromaticScale[12] = {@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"B♭", @"B"};
static NSInteger MScale[5] = {0, 4, 7, 12, 16};
static NSInteger mScale[5] = {0, 3, 7, 12, 15};
static NSInteger sScale[5] = {0, 4, 7, 10, 12};
static NSInteger MsScale[5] = {0, 4, 7, 11, 12};
static NSInteger msScale[5] = {0, 3, 7, 10, 12};
static NSInteger nScale[5] = {0, 4, 7, 10, 14};
static NSInteger MnScale[5] = {0, 3, 7, 11, 14};
static NSInteger mnScale[5] = {0, 3, 7, 10, 14};
static NSInteger yScale[5] = {0, 4, 7, 9, 12};
static NSInteger myScale[5] = {0, 3, 7, 9, 12};
static NSInteger susScale[5] = {0, 5, 7, 12, 17};

@implementation UISequenceView

@synthesize sequenceButtons, sequence, player, clearButton, popoverController;

-(NSString *) notatedVariation:(NSString *)variation /* Returns the notation of the variation */
{   
    NSLog(@"varitation in function: %@", variation);
    if (variation == @"major") return @"";
    else if (variation == @"minor") return @"m";
    else if (variation == @"7") return @"7";
    else if (variation == @"maj7") return @"M7";
    else if (variation == @"m7") return @"m7";
    else if (variation == @"9") return @"9";
    else if (variation == @"maj9") return @"M9";
    else if (variation == @"m9") return @"m9";
    else if (variation == @"6") return @"6";
    else if (variation == @"m6") return @"m6";
    else if (variation == @"sus4") return @"sus4";
    else return @"";
}

-(void)loadSequence:(NSMutableArray *)seq 
{
    [sequence removeAllObjects];
    [sequence addObjectsFromArray:seq];
    [sequenceButtons removeAllObjects];
    if ([sequence count] > 0) currentIndex = 0;
    else currentIndex = -1;
    
    for (int i=0; i<[sequence count]; i++) {
        Chord *chord = [sequence objectAtIndex:i];
        UIColor *buttonColor = [UIColor blackColor];
        if (i == currentIndex) buttonColor = [UIColor redColor];
        
        /* Configure new button */
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = i;
        if (i == 0) 
            button.frame = CGRectMake(ORIGIN_X, ORIGIN_Y, B_WIDTH, B_HEIGHT);
        else if ([[sequenceButtons lastObject] frame].origin.x + B_WIDTH < V_WIDTH - 100) 
            button.frame = CGRectMake(B_HSPACE + [[sequenceButtons lastObject] frame].origin.x + B_WIDTH, [[sequenceButtons lastObject] frame].origin.y, B_WIDTH, B_HEIGHT);
        else // No more space
            button.frame = CGRectMake(ORIGIN_X, [[sequenceButtons lastObject] frame].origin.y + B_HEIGHT + B_VSPACE, B_WIDTH, B_HEIGHT);
        
        NSString *var = [self notatedVariation: chord.variation];
        NSString *base = chromaticScale[chord.number];
        NSLog(@"title and var: %@ %@", chord.title, chord.variation);
        [button setTitle: [base stringByAppendingString:var] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [button setTitleColor:buttonColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        /* Add gesture recognizer for long-presses */
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [button addGestureRecognizer:longPressGestureRecognizer];
        
        [sequenceButtons addObject:button];
        NSLog(@"sequence count == %d", [sequence count]);
        NSLog(@"sequenceButtons count == %d", [sequenceButtons count]);
        [self addSubview:button];

    }
}

- (void)noteOff2:(NSNumber *)note
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
	appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x90, [note intValue], 0x00);
}

- (void)stopAllNotes
{
    for (int i = 0; i < 127; i++) {
        [self noteOff2:[NSNumber numberWithInt:i]];
    }
}

- (void)playChordWithRoot:(unsigned int)root withVariation:(NSString *) var
{
    /* make these public so panInBox can send noteOff command to them */
    NSNumber *tonic;
    NSNumber *mediant;
    NSNumber *dominant;
    tonic = [NSNumber numberWithInt:root];
    if (var == @"major") {
        mediant = [NSNumber numberWithInt:root+4]; 
    } else if (var == @"minor") {
        mediant = [NSNumber numberWithInt:root+3];
    }
    dominant = [NSNumber numberWithInt:root+7];
    [self noteOn:tonic];
    [self noteOn:mediant];
    [self noteOn:dominant];
    //[self performSelector:@selector(noteOff:) withObject:tonic afterDelay:5.0];
    //[self performSelector:@selector(noteOff:) withObject:mediant afterDelay:5.0];
    //[self performSelector:@selector(noteOff:) withObject:dominant afterDelay:5.0];
}

- (void)stopChordWithRoot:(unsigned int)root
{
    /* make these public so panInBox can send noteOff command to them */
    NSNumber *tonic;
    NSNumber *mediantMajor;
    NSNumber *mediantMinor;
    NSNumber *dominant;
    tonic = [NSNumber numberWithInt:root];
    mediantMajor = [NSNumber numberWithInt:root+4]; 
    mediantMinor = [NSNumber numberWithInt:root+3];
    dominant = [NSNumber numberWithInt:root+7];
    [self noteOff:tonic];
    [self noteOff:mediantMajor];
    [self noteOff:mediantMinor];
    [self noteOff:dominant];
    //[self performSelector:@selector(noteOff:) withObject:tonic afterDelay:5.0];
    //[self performSelector:@selector(noteOff:) withObject:mediant afterDelay:5.0];
    //[self performSelector:@selector(noteOff:) withObject:dominant afterDelay:5.0];
}

- (void)noteOn:(NSNumber *)note
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x90, 60 + [note intValue], 0x7F);
}

- (void)noteOff:(NSNumber *)note
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
	appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x90, 60 + [note intValue], 0x00);
}


- (void) clearButtonTriggered:(id) sender
{
    // Clear array
    currentIndex = -1;
    [sequence removeAllObjects];
    for (UIButton *button in sequenceButtons) {
        [button removeFromSuperview];
    }
    [sequenceButtons removeAllObjects];
    NSLog(@"sequence and sequenceButtons have %d and %d members", [sequence count], [sequenceButtons count]);
}

- (void)initialize
{
    NSLog(@"initializing...");
    sequence = [NSMutableArray array];
    sequenceButtons = [NSMutableArray array];
    currentIndex = -1;
    clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clearButton.frame = CGRectMake(15, 290, 80, 30);
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [clearButton addTarget:self action:@selector(clearButtonTriggered:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clearButton];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(NSString *) chordOfTag:(NSInteger)tag /* Returns chord name of tag */
{
    switch (tag) {
        case 0:
            return @"C";
            break;
        case 1:
            return @"Cm";
            break;
        case 2:
            return @"C#";
            break;
        case 3:
            return @"C#m";
            break;
        case 4:
            return @"D";
            break;
        case 5:
            return @"Dm";
            break;
        case 6:
            return @"D#";
            break;
        case 7:
            return @"D#m";
            break;
        case 8:
            return @"E";
            break;
        case 9:
            return @"Em";
            break;
        case 10:
            return @"F";
            break;
        case 11:
            return @"Fm";
            break;
        case 12:
            return @"F#";
            break;
        case 13:
            return @"F#m";
            break;
        case 14:
            return @"G";
            break;
        case 15:
            return @"Gm";
            break;
        case 16:
            return @"G#";
            break;
        case 17:
            return @"G#m";
            break;
        case 18:
            return @"A";
            break;
        case 19:
            return @"Am";
            break;
        case 20:
            return @"B♭";
            break;
        case 21:
            return @"B♭m";
            break;
        case 22:
            return @"B";
            break;
        case 23:
            return @"Bm";
            break;
        default:
            return @"X";
    }
}

-(NSString *) chordOfTonic:(NSInteger)tonic /* Returns chord name of tag */
{
    switch (tonic) {
        case 0:
            return @"C";
            break;
        case 1:
            return @"C#";
            break;
        case 2:
            return @"D";
            break;
        case 3:
            return @"D#";
            break;
        case 4:
            return @"E";
            break;
        case 5:
            return @"F";
            break;
        case 6:
            return @"F#";
            break;
        case 7:
            return @"G";
            break;
        case 8:
            return @"G#";
            break;
        case 9:
            return @"A";
            break;
        case 10:
            return @"B♭";
            break;
        case 11:
            return @"B";
            break;
        default:
            return @"X";
    }
}

-(NSString *) varOfTag:(NSInteger)tag /* Returns variation (minor | major) of tag */
{
    if (tag%2==0) return @"major";
    else return @"minor";
}

-(NSNumber *) tonicOfTag:(NSInteger)tag /* Returns tonic number of tag */
{
    switch (tag) {
        case 0:
            return [NSNumber numberWithInt:0];
            break;
        case 1:
            return [NSNumber numberWithInt:0];
            break;
        case 2:
            return [NSNumber numberWithInt:1];
            break;
        case 3:
            return [NSNumber numberWithInt:1];
            break;
        case 4:
            return [NSNumber numberWithInt:2];
            break;
        case 5:
            return [NSNumber numberWithInt:2];
            break;
        case 6:
            return [NSNumber numberWithInt:3];
            break;
        case 7:
            return [NSNumber numberWithInt:3];
            break;
        case 8:
            return [NSNumber numberWithInt:4];
            break;
        case 9:
            return [NSNumber numberWithInt:4];
            break;
        case 10:
            return [NSNumber numberWithInt:5];
            break;
        case 11:
            return [NSNumber numberWithInt:5];
            break;
        case 12:
            return [NSNumber numberWithInt:6];
            break;
        case 13:
            return [NSNumber numberWithInt:6];
            break;
        case 14:
            return [NSNumber numberWithInt:7];
            break;
        case 15:
            return [NSNumber numberWithInt:7];
            break;
        case 16:
            return [NSNumber numberWithInt:8];
            break;
        case 17:
            return [NSNumber numberWithInt:8];
            break;
        case 18:
            return [NSNumber numberWithInt:9];
            break;
        case 19:
            return [NSNumber numberWithInt:9];
            break;
        case 20:
            return [NSNumber numberWithInt:10];
            break;
        case 21:
            return [NSNumber numberWithInt:10];
            break;
        case 22:
            return [NSNumber numberWithInt:11];
            break;
        case 23:
            return [NSNumber numberWithInt:11];
            break;
        default:
            return [NSNumber numberWithInt:-1];
    }
}

- (NSString *) getTitleOfCurrentChord 
{
    return [[sequence objectAtIndex:currentIndex] title];
}




-(IBAction)buttonTapped:(id)sender
{
    UIButton *newButton = (UIButton *)sender;
    UIButton *oldButton = [sequenceButtons objectAtIndex:currentIndex];
    [oldButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [newButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    currentIndex = [sequenceButtons indexOfObject:sender];
}
    
- (void)popoverControllerDidDismissPopover: (UIPopoverController *)popoverController 
{    
    NSLog(@"popover controller %@ dismissed", [popoverController description]);
}

-(void)changedVariationTo:(NSString *)variation
{
    NSString *oldVariation = [[sequence objectAtIndex:longPressedButtonIndex] variation];
    [[sequence objectAtIndex:longPressedButtonIndex] setVariation:variation];
    NSLog(@"Chord %@ changed variation to %@", [[[sequenceButtons objectAtIndex:longPressedButtonIndex] titleLabel] text], [[sequence objectAtIndex:longPressedButtonIndex] variation]);
    NSString *var = [self notatedVariation: variation];
    UIButton *button = [sequenceButtons objectAtIndex:longPressedButtonIndex];
    NSString *base = chromaticScale[[[sequence objectAtIndex:longPressedButtonIndex] number]];
    [button setTitle: [base stringByAppendingString:var] forState:UIControlStateNormal];
}

-(void) handleLongPress:(UILongPressGestureRecognizer *)sender
{
    longPressedButtonIndex = [sender view].tag;
    NSLog(@"button %d long-pressed", longPressedButtonIndex);
    CGPoint pos = [sender locationInView:self];
    CGRect rect = CGRectMake(pos.x, pos.y, 5, 5);
    if (sender.state == UIGestureRecognizerStateBegan) {
        /* Add popover view */
        NSLog(@"%@", NSStringFromCGRect(rect));
        VariationViewController *variations = [[VariationViewController alloc] init];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:variations]; 
        [popover setPopoverContentSize:CGSizeMake(200, 300) animated:YES];
        popover.delegate = self;
        self.popoverController = popover;
        rect.size.width = MIN(rect.size.width, 100); 
        [popover presentPopoverFromRect:rect inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
}

/* Converts chordTag to MIDI chord numbers. */
- (void) addChord:(NSInteger)chordTag // old chord tag notation from ViewController.m
{
    UIColor *buttonColor = [UIColor blackColor];
    if (currentIndex == -1) {
        currentIndex = 0;
        buttonColor = [UIColor redColor];
    }
    
    /* Configure new button */
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = [sequence count];
    if ([sequence count] == 0) 
        button.frame = CGRectMake(ORIGIN_X, ORIGIN_Y, B_WIDTH, B_HEIGHT);
    else if ([[sequenceButtons lastObject] frame].origin.x + B_WIDTH < V_WIDTH - 100) 
        button.frame = CGRectMake(B_HSPACE + [[sequenceButtons lastObject] frame].origin.x + B_WIDTH, [[sequenceButtons lastObject] frame].origin.y, B_WIDTH, B_HEIGHT);
    else // No more space
        button.frame = CGRectMake(ORIGIN_X, [[sequenceButtons lastObject] frame].origin.y + B_HEIGHT + B_VSPACE, B_WIDTH, B_HEIGHT);
    [button setTitle: [self chordOfTag:chordTag] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [button setTitleColor:buttonColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    /* Add gesture recognizer for long-presses */
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [button addGestureRecognizer:longPressGestureRecognizer];
    
    /* Add new chord into sequence by converting chordTag into numerical tonic value and type of variation */
    [sequence addObject:[[Chord alloc] initWithChordNumber:[[self tonicOfTag:chordTag] intValue] andVariation:[self varOfTag:chordTag]]];
    [sequenceButtons addObject:button];
    NSLog(@"sequence count == %d", [sequence count]);
    NSLog(@"sequenceButtons count == %d", [sequenceButtons count]);
    [self addSubview:button];
}

-(void) playChord:(Chord *)chord 
{   
    [self playChordWithRoot:chord.number withVariation:chord.variation];
}


-(void) playCurrentChord 
{
    if (currentIndex > -1) {
        Chord *currentChord = [sequence objectAtIndex:currentIndex];
        [self playChord:currentChord];
    } else NSLog(@"No chords to play");
}

-(void) ofCurrentChordPlayNote:(int)ith
{
    if (currentIndex > -1) {
        Chord *currentChord = [sequence objectAtIndex:currentIndex];
        if (currentChord.variation == @"major")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+MScale[ith]]];
        else if (currentChord.variation == @"minor")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+mScale[ith]]];
        else if (currentChord.variation == @"7")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+sScale[ith]]];
        else if (currentChord.variation == @"maj7")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+MsScale[ith]]];
        else if (currentChord.variation == @"m7")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+msScale[ith]]];
        else if (currentChord.variation == @"9")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+nScale[ith]]];
        else if (currentChord.variation == @"maj9")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+MnScale[ith]]];
        else if (currentChord.variation == @"m9")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+mnScale[ith]]];
        else if (currentChord.variation == @"6")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+yScale[ith]]];
        else if (currentChord.variation == @"m6")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+myScale[ith]]];
        else if (currentChord.variation == @"sus4")
            [self noteOn:[NSNumber numberWithInt:currentChord.number+susScale[ith]]];
    } else NSLog(@"No chords to play");
}

-(void) moveForward 
{
    UIButton *currentButton;
    if ([sequence count] != 0) {
        if (currentIndex >= 0) {
            currentButton = [sequenceButtons objectAtIndex:currentIndex];   
            [currentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        currentIndex++;
        if (currentIndex > ([sequenceButtons count]-1)) {
            NSLog(@"back to first chord");
            currentIndex = 0;
        }
        currentButton = [sequenceButtons objectAtIndex:currentIndex];
        //[self playCurrentChord];
        [currentButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    } else 
        NSLog(@"did not move forward");
}

@end
