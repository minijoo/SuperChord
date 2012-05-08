//
//  Chord.m
//  SimpleApp
//
//  Created by Music2 on 4/1/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "Chord.h"

@implementation Chord

@synthesize title, variation, number;

-(id)initWithChordNumber:(int) chordNumber andVariation:(NSString *)var
{
    self.number = chordNumber;
    self.variation = var;
    return self;
}

-(void)setVariation:(NSString *)var {
    variation = var;
}

-(void)setTitle:(NSString *)t {
    title = t;
}

@end
