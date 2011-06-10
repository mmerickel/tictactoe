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


@interface Model : NSObject 
{
    NSString * markString;
    BoardMark  myMarkType;
    BOOL isMyTurn;
    NSString * client_id;
    NSString * game_id;
    NSString * myName;
    int cursor;
}
@property (readonly) NSString * markString;
@property (readonly) BoardMark myMarkType;
@property (readonly) BOOL isMyTurn;

@property (retain, readonly) NSString* client_id;
@property (retain, readonly) NSString* game_id;
@property (retain, readonly) NSString* myName;

@property (readonly) int cursor;

+(Model*)sharedModel;
- (void) login;
- (void) getBoardUpdate;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
