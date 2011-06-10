//
//  TicTacToeViewController.h
//  TicTacToe
//
//  Created by Steven Mitchell on 6/3/11.
//  Copyright 2011 Componica, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface TicTacToeViewController : UIViewController 
{
    float maxYPosOfBoard; 
    float oneThirdOfBoard;
    float markSpacer;
    NSString * markString;
    UIImageView * selectedView;
}
 @property float maxYPosOfBoard;
 @property float oneThirdOfBoard;
 @property float markSpacer;

- (void) paintBoardState;
- (void) markUpBoard;
- (void) checkWinner;
- (BOOL) isSelectableX:(int)X Y:(int)Y;
@end
