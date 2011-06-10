//
//  TicTacToeAppDelegate.h
//  TicTacToe
//
//  Created by Steven Mitchell on 6/3/11.
//  Copyright 2011 Componica, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TicTacToeViewController;

@interface TicTacToeAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TicTacToeViewController *viewController;

@end
