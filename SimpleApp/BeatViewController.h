//
//  BeatViewController.h
//  SimpleApp
//
//  Created by Music2 on 5/9/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeatViewController : UITableViewController {
    
    NSInteger checkedSection, checkedRow;
    NSMutableArray *listOfFourFour;
    NSMutableArray *listOfThreeFour;
    UINavigationController *navigationController;
}


@end
