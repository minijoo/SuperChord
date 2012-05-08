//
//  Chord.h
//  SimpleApp
//
//  Created by Music2 on 4/1/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chord : NSObject {
    NSString *title;
    NSInteger number;
    NSString *variation;
}

@property(retain) NSString *title;
@property() NSInteger number;
@property(retain) NSString *variation;

-(id)initWithChordNumber:(int) chordNumber andVariation:(NSString *) var;
-(void)setVariation:(NSString *)var;
-(void)setTitle:(NSString *)t;

@end
