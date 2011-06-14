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
        client_id = @"0";
        game_id = @"0";
        myName = @"";
        gameState = Pre_Connect;
        cursor = 0;
        
        //[self login];
	}
    
	return self;
}
- (void) login
{
    NSString* urlString = 
    @"http://aws.merickel.org/tictactoe/api/play";
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setPostValue:@"1234" forKey:@"client_id"]; 
    [request setPostValue:myName forKey:@"name"];

    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        id objectFromKey = nil;
        NSLog(@"%@", responseString);
        
        // Store incoming data into a string
        NSString *jsonString = [NSString stringWithString:responseString];
        
        // Create a dictionary from the JSON string
        NSDictionary *results = [jsonString JSONValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self userInfo:results];
        
        objectFromKey = [results objectForKey:@"server error"];
        if (objectFromKey == nil)
        {
            objectFromKey = [results objectForKey:@"name"];
            if (objectFromKey != nil)
            {
                myName = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
                NSLog(@"%@", myName);
            }
            objectFromKey = [results objectForKey:@"game_id"];
            if (objectFromKey != nil)
            {
                game_id = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
                NSLog(@"%@", game_id);
            }
            objectFromKey = [results objectForKey:@"client_id"];
            if (objectFromKey != nil)
            {
                client_id = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
                NSLog(@"client_id is %@", client_id);
            }
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
    }];    
    //[request setDelegate:self];
    [request startSynchronous];  
    
    if(game_id != @"0"  &&  game_id != nil)
    {
        [self getBoardUpdate];
    }
    
}


- (void) getBoardUpdate
{
    NSString* urlString ;

    urlString = [NSString stringWithFormat:@"http://aws.merickel.org/tictactoe/api/updates/%@", game_id]; 
    urlString = [urlString stringByAppendingFormat:@"?cursor=%d", cursor]; 
    
    NSLog(urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setShouldAttemptPersistentConnection:YES];
    [request setPersistentConnectionTimeoutSeconds:60];

    [request setDelegate:self];
    [request startAsynchronous];        

}

- (BOOL) movePosition:(int)position
{
    NSString * urlString = @"http://aws.merickel.org/tictactoe/api/move";
    NSString * posStr = [NSString stringWithFormat:@"%d", position];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:client_id forKey:@"client_id"];
    [request setPostValue:posStr forKey:@"position"];
    
    [request setDelegate:self];
    [request startAsynchronous];    
    
    return YES;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    id objectFromKey = nil;
    
    // Store incoming data into a string
    NSString *jsonString = [request responseString];
    NSLog(@"%@", jsonString);
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [jsonString JSONValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self userInfo:results];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self];
    
    objectFromKey = [results objectForKey:@"error"];
    if (objectFromKey == nil)
    {
        objectFromKey = [results objectForKey:@"cursor"];
        if (objectFromKey != nil)
        {
            NSString * temp = objectFromKey;
            cursor = [temp intValue];
            temp = [@"Cursor is " stringByAppendingFormat:@"%d", cursor];
            NSLog( temp );
        }
        objectFromKey = [results objectForKey:@"player"];
        if (objectFromKey != nil)
        {
            //player = objectFromKey;
            //NSLog(isMyTurn);
        }
        objectFromKey = [results objectForKey:@"type"];
        if (objectFromKey != nil)
        {
            type = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
            NSLog(type);
        }
        objectFromKey = [results objectForKey:@"timestamp"];
        if (objectFromKey != nil)
        {
            timestamp = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
            NSLog(timestamp);
        }
        objectFromKey = [results objectForKey:@"board"];
        if (objectFromKey != nil)
        {
            //markString = objectFromKey;
            markString = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
            NSLog(objectFromKey);
        }
        objectFromKey = [results objectForKey:@"playerX"];
        if (objectFromKey != nil)
        {
            NSLog(myName); 
            NSString * temp = [NSString stringWithFormat:@"%@", objectFromKey];
            if ([myName isEqualToString:temp] )
            {
                NSLog(@"I am Xs");   
                myMarkType = X;
            }
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self];
        }
        objectFromKey = [results objectForKey:@"playerO"];
        if (objectFromKey != nil)
        {
            NSLog(myName); 
            NSString * temp = [NSString stringWithFormat:@"%@", objectFromKey];
            if ([myName isEqualToString:temp] )
            {
                NSLog(@"I am Os");   
                myMarkType = O;
            }
        }
    }
    [self getBoardUpdate];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSString * errStr = error.domain;
    int i = error.code;
    NSLog([NSString stringWithFormat:@"requestFailed: %d %@", i, errStr]);
    [self getBoardUpdate];
}
@end
