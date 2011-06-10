//
//  Model.m
//  TicTacToe
//
//  Created by Steven Mitchell on 6/10/11.
//  Copyright 2011 Componica, LLC. All rights reserved.
//

#import "Model.h"
//#import "SBJson.h"

@implementation Model
@synthesize markString;
@synthesize myMarkType;
@synthesize isMyTurn;

@synthesize client_id;
@synthesize game_id;
@synthesize myName;

@synthesize cursor;

static Model* _sharedModel = nil;

+(Model*)sharedModel
{
	@synchronized([Model class])
	{
		if (!_sharedModel)
			[[self alloc] init];
        
		return _sharedModel;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([Model class])
	{
		NSAssert(_sharedModel == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedModel = [super alloc];
		return _sharedModel;
	}
    
	return nil;
}

-(id)init 
{
	self = [super init];
    cursor = 0;
	if (self != nil) 
    {
		markString = @"_________";
		myMarkType = X;
		isMyTurn = YES;
        [self login];
	}
    
	return self;
}
- (void) login
{
    NSString* urlString = 
    @"http://aws.merickel.org/tictactoe/api/play";
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:@"client_id" forKey:@"920d14a9a2204d8bbc553ef94f6d6773"];
    [request setPostValue:@"name" forKey:@"Dan"];
    
    [request setDelegate:self];
    [request startAsynchronous];    
}

- (void) getBoardUpdate
{
    NSString* urlString ;

    urlString = [@"http://aws.merickel.org/tictactoe/api/updates/" stringByAppendingString:game_id];

    NSLog(urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request startAsynchronous];        
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    id objectFromKey = nil;
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(responseString);
    
    // Store incoming data into a string
    NSString *jsonString = [[NSString alloc] initWithString:responseString];
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [jsonString JSONValue];
    
    objectFromKey = [results objectForKey:@"name"];
    if (objectFromKey != nil)
    {
        myName = objectFromKey;
        NSLog(myName);
    }
    objectFromKey = [results objectForKey:@"game_id"];
    if (objectFromKey != nil)
    {
        game_id = objectFromKey;
        NSLog(game_id);
    }
    objectFromKey = [results objectForKey:@"client_id"];
    if (objectFromKey != nil)
    {
        client_id = objectFromKey;
        NSLog(client_id);
    }
    objectFromKey = [results objectForKey:@"cursor"];
    if (objectFromKey != nil)
    {
        NSString * temp = objectFromKey;
        cursor = [temp intValue];
        NSLog(cursor);
    }
    objectFromKey = [results objectForKey:@"player"];
    if (objectFromKey != nil)
    {
        //player = objectFromKey;
        NSLog(client_id);
    }
    if(cursor == 0 )
    {
        [self getBoardUpdate];
    }
    // Use when fetching binary data
//    NSData *responseData = [request responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    //NSString * errStr = error.domain;
    //int i = error.code;
}

@end
