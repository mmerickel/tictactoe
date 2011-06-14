//
//  TicTacToeViewController.m
//  TicTacToe
//
//  Created by Steven Mitchell on 6/3/11.
//  Copyright 2011 Componica, LLC. All rights reserved.
//

#import "TicTacToeViewController.h"

@implementation TicTacToeViewController

@synthesize maxYPosOfBoard;
@synthesize oneThirdOfBoard;
@synthesize markSpacer;

@synthesize displayName;
@synthesize buttonText;
@synthesize textArea;

- (void) paintBoardState
{
    UIImageView * playAreaView;
    CGRect frameRect;
    CGPoint rectPoint;
    float newYPos;
    float boardHeight = 0.0f;
    float appHeight = 0.0f;
    float topBarHeight = 0.0f;
    float xHeight = 0.0f;
    float oHeight = 0.0f;
    markSpacer = 0.0f;
    oneThirdOfBoard = 0.0f;
    
    // the playing background
    UIImage * image = [UIImage imageNamed:@"board.png"];

    // get the model board state string
    markString = [Model sharedModel].markString;
    
    // get some size info
    // assume square images
    appHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    boardHeight = image.size.height;
    oneThirdOfBoard = boardHeight/3;
    topBarHeight = appHeight - boardHeight;
    
    image = [UIImage imageNamed:@"x.png"];
    xHeight = image.size.height;
    image = [UIImage imageNamed:@"o.png"];
    oHeight = image.size.height;

    //use the largest mark
    if (oHeight > xHeight) 
    {
        xHeight = oHeight;  //we will just use xHeight for operations
    }
    // how far from the edge should we move the mark image to center it?
    markSpacer = (boardHeight-(3*xHeight))/6;
    
    // load background
    image = [UIImage imageNamed:@"board.png"];
    playAreaView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:playAreaView];
    
    // locate the playing board at the bottom 460-320=140 points
    frameRect = playAreaView.frame;
    rectPoint = frameRect.origin;
    newYPos = rectPoint.y + topBarHeight;
    maxYPosOfBoard = newYPos;
    playAreaView.frame = CGRectMake(0.0f, newYPos, 
                                    playAreaView.frame.size.width, 
                                    playAreaView.frame.size.height);    
    //self.view.frame = playAreaView.frame;
    [playAreaView release];

    markString = [Model sharedModel].markString;
    [self markUpBoard];
    [self checkWinner];
}
- (void) checkWinner
{
    UIImageView * playAreaView;
    UIImage * image = nil;
    
    if( [markString characterAtIndex:0] == [markString characterAtIndex:1] &&
        [markString characterAtIndex:0] == [markString characterAtIndex:2]  &&
        [markString characterAtIndex:0] != '_')
    {
        image = [UIImage imageNamed:@"(0,0)(2,0).png"];
    }
    if( [markString characterAtIndex:3] == [markString characterAtIndex:4] &&
       [markString characterAtIndex:3] == [markString characterAtIndex:5]  &&
       [markString characterAtIndex:3] != '_')

    {
        image = [UIImage imageNamed:@"(0,1)(2,1).png"];
    }
    if( [markString characterAtIndex:6] == [markString characterAtIndex:7] &&
       [markString characterAtIndex:6] == [markString characterAtIndex:8]  &&
       [markString characterAtIndex:6] != '_')

    {
        image = [UIImage imageNamed:@"(0,2)(2,2).png"];
    }
    if( [markString characterAtIndex:0] == [markString characterAtIndex:3] &&
       [markString characterAtIndex:0] == [markString characterAtIndex:6]  &&
       [markString characterAtIndex:0] != '_')

    {
        image = [UIImage imageNamed:@"(0,0)(0,2).png"];
    }
    if( [markString characterAtIndex:1] == [markString characterAtIndex:4] &&
       [markString characterAtIndex:1] == [markString characterAtIndex:7]  &&
       [markString characterAtIndex:1] != '_')

    {
        image = [UIImage imageNamed:@"(1,0)(1,2).png"];
    }
    if( [markString characterAtIndex:2] == [markString characterAtIndex:5] &&
       [markString characterAtIndex:2] == [markString characterAtIndex:8]  &&
       [markString characterAtIndex:2] != '_')

    {
        image = [UIImage imageNamed:@"(2,0)(2,2).png"];
    }
    
    if( [markString characterAtIndex:0] == [markString characterAtIndex:4] &&
       [markString characterAtIndex:0] == [markString characterAtIndex:8]  &&
       [markString characterAtIndex:0] != '_')

    {
        image = [UIImage imageNamed:@"(0,0)(2,2).png"];
    }
    
    if( [markString characterAtIndex:2] == [markString characterAtIndex:4] &&
       [markString characterAtIndex:2] == [markString characterAtIndex:6]  &&
       [markString characterAtIndex:2] != '_')

    {
        image = [UIImage imageNamed:@"(0,2)(2,0).png"];
    }
    
    
    playAreaView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:playAreaView];
    if (image != nil) 
    {
        // shift the slash down
        playAreaView.frame = CGRectMake(0, maxYPosOfBoard, 
                                        playAreaView.frame.size.width, 
                                        playAreaView.frame.size.height);    
        //self.view.frame = playAreaView.frame;
        [playAreaView release];
    }
    
}
- (void) markUpBoard
{
    UIImageView * playAreaView;

    BOOL bLocateCursor = NO;
    if (markString.length == 9)/*magic tictactoe number*/
    {
        int row = 0;
        int col = 0;
        float deltaX = 0.0f;
        float deltaY = maxYPosOfBoard;// this puts us at the origin of the game board
        for (int ii=0; ii < 9; ii++) 
        {
            UIImage * image;
            switch ([markString characterAtIndex:ii]) 
            {
                case 'X':
                case 'x':
                    image = [UIImage imageNamed:@"x.png"];
                    break;
                case 'O':
                case 'o':
                    image = [UIImage imageNamed:@"o.png"];
                    break;
                default:
                    image = nil;
                    break;
            }
            
            if (image != nil) 
            {
                playAreaView = [[UIImageView alloc] initWithImage:image];
                [self.view addSubview:playAreaView];
            
                // locate the mark within the board
                deltaX = ((col%3) * oneThirdOfBoard) + markSpacer;
                deltaY = maxYPosOfBoard + (((row%3)) * oneThirdOfBoard) + markSpacer;
                playAreaView.frame = CGRectMake(deltaX, deltaY, 
                                                playAreaView.frame.size.width, 
                                                playAreaView.frame.size.height);    
                //self.view.frame = playAreaView.frame;
                [playAreaView release];
            }
            else
            {
                if(!bLocateCursor)
                {
                    if([Model sharedModel].myMarkType == X)
                    {
                        image = [UIImage imageNamed:@"x_reverse.png"];
                    }
                    else
                    {
                        image = [UIImage imageNamed:@"o_reverse.png"];
                    }
                    selectedView  = [[UIImageView alloc] initWithImage:image];
                    [selectedView setHidden: YES];
                    [self.view addSubview:selectedView];
                    
                    deltaX = ((col%3) * oneThirdOfBoard) + markSpacer;
                    deltaY = maxYPosOfBoard + (((row%3)) * oneThirdOfBoard) + markSpacer;
                    selectedView.frame = CGRectMake(deltaX, deltaY, 
                                                    selectedView.frame.size.width, 
                                                    selectedView.frame.size.height);    
                    bLocateCursor = YES;
                }
            }

            col++;
            if (col>2) 
            {
                col = 0;
                row++;

            }
        }
    }
}

- (IBAction) connectButton;
{
    if([[buttonText currentTitle] isEqualToString:@"Quit"] )
    {
        [[Model sharedModel] quit];
    }
    if([[buttonText currentTitle] isEqualToString:@"Connect"] )
    {
        [[Model sharedModel] loginname:displayName.text];
    }
}
- (IBAction) enterText
{
    [[Model sharedModel] myName:displayName];
}

- (IBAction) backgroundButton:(id)sender
{
    NSLog(@"backgroundButton touched...");
    [displayName resignFirstResponder];
}
- (IBAction) textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Dismiss the keyboard, if it is shown
    if([displayName isFirstResponder]) {
        [displayName resignFirstResponder];
    }
        
    int xThird = 0;
    int yThird = 0;
    BOOL selectable = NO;
    
    NSUInteger numTaps = [[touches anyObject] tapCount];
    
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    
    // Are we on the board?
    if (pt.y >= [self maxYPosOfBoard])
    {
        xThird = (pt.x/oneThirdOfBoard) + 1;
        yThird = ((pt.y-maxYPosOfBoard)/oneThirdOfBoard) + 1;
        
        selectable = [self isSelectableX:xThird Y:yThird];
        
        if( selectable )
        {
            if (numTaps < 2)
            {   
                // move the selection cursor to this place
                int deltaX = (((xThird-1)%3) * oneThirdOfBoard) + markSpacer;
                int deltaY = maxYPosOfBoard + ((((yThird-1)%3)) * oneThirdOfBoard) + markSpacer;
                selectedView.frame = CGRectMake(deltaX, deltaY, 
                                                selectedView.frame.size.width, 
                                                selectedView.frame.size.height); 
                
                [selectedView setHidden: NO];
            }
            else
            {
                int movePos = ( (yThird-1) * 3 ) + (xThird-1);
                [[Model sharedModel] movePosition:movePos];
            }
        }
        else
        {
            [selectedView setHidden: YES];
        }
    }
}

- (BOOL) isSelectableX:(int)X Y:(int)Y
{
    BOOL retVal = NO;
    int col = 0;
    int row = 0;
    char uScore;
    
    //    int len = [markString length];
    for (int ii=0; ii < 9; ii++) 
    {
        if ( (col+1) == X && (row+1) == Y)
        {
            uScore = [markString characterAtIndex:ii];
            if( [markString characterAtIndex:ii] == '_')
            {
                retVal = YES;
            }
            break;
        }
        col++;
        if (col>2) 
        {
            col = 0;
            row++;
            
        }
    }
    return retVal;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self paintBoardState];    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:) 
                                                 name:@"TestNotification"
                                               object:nil];// any object can call this

    [super viewDidLoad];
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    NSString * status = @"";
    NSLog(@"Received test notification in TicTacToeViewController");
    if ([[notification name] isEqualToString:@"TestNotification"])
    {
        NSDictionary * local = [notification userInfo];
        id objectFromKey = nil;
        objectFromKey = [local objectForKey:@"server error"];
        if (objectFromKey == nil)
        {
            objectFromKey = [local objectForKey:@"name"];
            if (objectFromKey != nil)
            {
                displayName.text = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
            }
            objectFromKey = [local objectForKey:@"game_id"];
            if (objectFromKey != nil)
            {
                [buttonText setTitle:@"Quit" forState:UIControlStateNormal] ;
                //[buttonText setTitle:@"Quit" forState:UIControlStateSelected] ;
            }
            objectFromKey = [local objectForKey:@"board"];
            if(objectFromKey != nil) 
            {
                //NSLog(@"Board: %@", objectFromKey);
                markString = [objectFromKey retain];
                [self paintBoardState];   
                //[self markUpBoard];
            }
            objectFromKey = [local objectForKey:@"type"];
            if (objectFromKey != nil)
            {
                status = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
                textArea.text = status;
                //type = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
                //NSLog(type);
            }
            objectFromKey = [local objectForKey:@"reason"];
            if (objectFromKey != nil)
            {
                status = [NSString stringWithFormat:@"%@: %@", status, [[NSString stringWithFormat:@"%@", objectFromKey] retain]];
                textArea.text = status;
                //type = [[NSString stringWithFormat:@"%@", objectFromKey] retain];
                //NSLog(type);
            }
        }

    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end    
