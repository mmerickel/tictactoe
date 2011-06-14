//
//  Model.h
//  TicTacToe
//
//  Created by Steven Mitchell on 6/10/11.
//  Copyright 2011 Componica, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

typedef enum  
{
    X,
    O,
    blank
} BoardMark;

typedef enum  
{
    Pre_Connect,
    Connecting,
    Connected_No_Board,
    Connected
} GameState;


@interface Model : NSObject 
{
    NSString * markString;
    BoardMark  myMarkType;
    BOOL isMyTurn;
    NSString * client_id;
    NSString * game_id;
    NSString * myName;
    NSString * type;
    NSString * timestamp;
    int cursor;
    GameState gameState;
}
@property (readonly) NSString * markString;
@property (readonly) BoardMark myMarkType;
@property (readonly) BOOL isMyTurn;

@property (retain, readonly) NSString* client_id;
@property (retain, readonly) NSString* game_id;
@property (retain) NSString* myName;

@property (readonly) int cursor;

+(Model*)sharedModel;
- (void) loginname:(NSString*)name;
- (void) quit;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void) getBoardUpdate;
//- (void) checkState;
- (BOOL) movePosition:(int)position;

@end
