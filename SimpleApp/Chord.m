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

static NSString *titleArchiveKey = @"title";
static NSString *variationArchiveKey = @"variation";
static NSString *numberArchiveKey = @"number";

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self != nil) {
        title = [coder decodeObjectForKey:titleArchiveKey];
        variation = [coder decodeObjectForKey:variationArchiveKey];
        number = [coder decodeIntegerForKey:numberArchiveKey];
    }
    return self;
}   

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:title forKey:titleArchiveKey];
    [coder encodeObject:variation forKey:variationArchiveKey];
    [coder encodeInteger:number forKey:numberArchiveKey];
}

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
