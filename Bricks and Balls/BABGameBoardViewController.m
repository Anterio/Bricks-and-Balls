//
//  BABGameBoardViewController.m
//  Bricks and Balls
//
//  Created by Arthur Boia on 8/6/14.
//  Copyright (c) 2014 Arthur Boia. All rights reserved.
//

// create 5 different types of power ups (paddle size big, paddle size small, multi ball, ball size big, ball size small) - the power ups should look different
// set topScore for your singleton
// change the look of your game with images or colors (**make it unique to you**)
// if game over set currentLevel to 0
#import "BABGameBoardViewController.h"
#import "BABHeaderView.h"
#import "BABLevelData2.h"

@interface BABGameBoardViewController () <UICollisionBehaviorDelegate, UIAlertViewDelegate>
// create new class called "BABLevelData" as a subclass of NSObject

// make a method that will drop a uiview (gravity) from a broken brick like a powerup
// listen for it to collide with paddle
// randomly change size of paddle when powerup hit paddle
@end

@implementation BABGameBoardViewController
{
    UIDynamicAnimator * animator;
    UIDynamicItemBehavior * ballItemBehavior;
    UIDynamicItemBehavior * powerUpBehavior;
    UIDynamicItemBehavior * brickItemBehavior;
    UICollisionBehavior * collisionBehavior;
    UICollisionBehavior * collisionPowerUp;
    UIGravityBehavior * gravityBehavior;
    UIAttachmentBehavior * attachementBehavior;
    
    UIView * ball;
    UIView * paddle;
    
    UIButton * resetButton;
    UIView * powerUp;
    
    NSMutableArray * bricks;
    
    UILabel * livesLabel;
    UILabel * scoreLabel;
    
    UIButton * startButton;
    
    BABHeaderView * headerView;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        bricks = [@[]mutableCopy];
        
        headerView = [[BABHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        [self.view addSubview:headerView];
        
        animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        ballItemBehavior = [[UIDynamicItemBehavior alloc] init];
        ballItemBehavior.friction = 0;
        ballItemBehavior.elasticity = 1;
        ballItemBehavior.resistance = 0;
        ballItemBehavior.allowsRotation = NO;
        [animator addBehavior:ballItemBehavior];
        
        brickItemBehavior = [[UIDynamicItemBehavior alloc] init];
        brickItemBehavior.density = 10000000;
        [animator addBehavior:brickItemBehavior];
        
        gravityBehavior = [[UIGravityBehavior alloc] init];
        //        gravityBehavior.gravityDirection = CGVectorMake(0, 5);
        [animator addBehavior:gravityBehavior];
        
        collisionBehavior = [[UICollisionBehavior alloc] init];
        
        
        [collisionBehavior addBoundaryWithIdentifier:@"floor" fromPoint:CGPointMake(0, SCREEN_HEIGHT+20) toPoint:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT+20)];
        [collisionBehavior addBoundaryWithIdentifier:@"leftwall" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, SCREEN_HEIGHT)];
        [collisionBehavior addBoundaryWithIdentifier:@"ceiling" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(SCREEN_WIDTH, 0)];
        [collisionBehavior addBoundaryWithIdentifier:@"rightwall" fromPoint:CGPointMake(SCREEN_WIDTH, 0) toPoint:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        collisionBehavior.collisionDelegate = self;
        [animator addBehavior:collisionBehavior];
        
        collisionPowerUp = [[UICollisionBehavior alloc] init];
        //        collisionPowerUp.collisionDelegate = self;
        //
        //        [collisionPowerUp addBoundaryWithIdentifier:@"floor" fromPoint:CGPointMake(0, SCREEN_HEIGHT+20) toPoint:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT+20)];
        //        [collisionPowerUp addBoundaryWithIdentifier:@"leftwall" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, SCREEN_HEIGHT)];
        //        [collisionPowerUp addBoundaryWithIdentifier:@"ceiling" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(SCREEN_WIDTH, 0)];
        //        [collisionPowerUp addBoundaryWithIdentifier:@"rightwall" fromPoint:CGPointMake(SCREEN_WIDTH, 0) toPoint:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        //
        //        [animator addBehavior:collisionPowerUp];
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    paddle = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -100 )/2, SCREEN_HEIGHT -10, 100, 4)];
    paddle.backgroundColor = [UIColor blackColor];
    [self.view addSubview:paddle];
    
    [self showStartButton];
    
    resetButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -100) /2.0,(SCREEN_HEIGHT -100) /2.0, 100, 100)];
    [resetButton setTitle: @"START" forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetGame) forControlEvents:UIControlEventTouchUpInside];
    resetButton.backgroundColor = [UIColor grayColor];
    resetButton.layer.cornerRadius = 50;
    
}
-(void) powerUpDrops: (UIView *) brick
{
    
    
    powerUp = [[UIView alloc] initWithFrame:CGRectMake(brick.center.x, brick.center.y, 25, 25)];
    collisionPowerUp.collisionDelegate = self;
    powerUp.layer.cornerRadius = 12.5;
    powerUp.backgroundColor = [UIColor greenColor];
    [self.view addSubview:powerUp];
    
    [collisionPowerUp addItem:powerUp];
    [collisionPowerUp addItem:paddle];
    [gravityBehavior addItem:powerUp];
    [animator addBehavior:gravityBehavior];
    [animator addBehavior:collisionBehavior];
    
    
}


-(void)resetGame
{
    [resetButton removeFromSuperview];
    [self resetBricks];
    [self createBall];
}
-(void) startGame
{
    [startButton removeFromSuperview];
    [self resetBricks];
    [self createBall];
    headerView.lives = 3;
    headerView.score = 0;
    
}
-(void)resetBricks
{
    
    for (UIView * brick in bricks)
    {
        [brick removeFromSuperview];
        [brickItemBehavior removeItem:brick];
        [collisionBehavior removeItem:brick];
    }
    
    [bricks removeAllObjects];
    
    int colCount = [[[BABLevelData2 mainData] levelInfo][@"cols"] intValue];
    int rowCount = [[[BABLevelData2 mainData] levelInfo][@"rows"] intValue];
    int brickSpacing = 8;
    
    for (int col = 0; col < colCount; col++)
    {
        for (int row = 0; row < rowCount; row++)
        {
            float width = (SCREEN_WIDTH - (brickSpacing* colCount +1))/colCount;
            float height = ((SCREEN_HEIGHT/3) - (brickSpacing*rowCount))/rowCount;
            
            float x = brickSpacing + (width + brickSpacing) * col;
            float y = brickSpacing + (height + brickSpacing) * row +30;
            
            UIView * brick = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            
            CGFloat hue = (arc4random() % 256 / 256.0);
            CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
            CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
            
            NSLog(@"%f %f %f",hue,saturation,brightness);
            
            UIColor * brickColor =[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
            brick.backgroundColor = brickColor;
            
            [self.view addSubview:brick];
            [bricks addObject:brick];
            
            [collisionBehavior addItem:brick];
            [brickItemBehavior addItem:brick];
            
            
        }
        
        
        
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    attachementBehavior = [[UIAttachmentBehavior alloc] initWithItem:paddle attachedToAnchor:paddle.center];
    [animator addBehavior:attachementBehavior];
    
    [collisionBehavior addItem:paddle];
    [brickItemBehavior addItem:paddle];
}
-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if ([@"floor" isEqualToString:(NSString *)identifier])
    {
        
        UIView * ballItem = (UIView *) item;
        [collisionBehavior removeItem:ballItem];
        headerView.lives--;
        
        [ballItem removeFromSuperview];
        
        ball = nil;
        
        if (headerView.lives > 0)
        {
            [self createBall];
        }
        else
        {
            [self createBall];
            
        }
        
    }
    
//    else   //if it's not the ball then must be power up
//    {
//        
//        [self showStartButton];
//    }
    
    
    
    
}
-(void) showStartButton
{
    
    for (UIView * brick in bricks)
    {
        [brick removeFromSuperview];
        [brickItemBehavior removeItem:brick];
        [collisionBehavior removeItem:brick];
    }
    
    [bricks removeAllObjects];
    
    startButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, (SCREEN_HEIGHT-100)/2, 100, 100)];
    [startButton setTitle:@"START" forState:UIControlStateNormal];
    startButton.layer.cornerRadius = 50;
    [startButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    startButton.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:startButton];
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    
    if (headerView.lives == 0)
    {
        [self createBall];
        
        headerView.lives = 3;
        headerView.score = 0;
        
        [self resetBricks];
    }
}
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    
    
    if ([item1 isEqual:powerUp] || [item2 isEqual:powerUp])
        
    {
        
        [collisionPowerUp removeItem:powerUp];
        [powerUp removeFromSuperview];
        powerUp = nil;
        
        [UIView animateWithDuration:.3 animations:^{
            powerUp.alpha = 0;
            
        } completion:^(BOOL finished) {
            [powerUp removeFromSuperview];
        }];
        
        if (powerUp == nil)
        {
            CGRect frame = paddle.frame;
            frame.size.width = arc4random_uniform(100)+100;
            paddle.frame = frame;
        }
        
        return;
    }
    
    for (UIView * brick in [bricks copy])
    {
        if ([item1 isEqual:brick] || [item2 isEqual:brick])
        {
            headerView.score +=100;
            int random = arc4random_uniform(6);
            
            if (random==2)
            {
                [self powerUpDrops:brick];
            }
            
            
            [collisionBehavior removeItem:brick];
            scoreLabel.text = [NSString stringWithFormat:@" Score %d", headerView.score];
            [gravityBehavior addItem:brick];
            [bricks removeObjectIdenticalTo:brick];
            
            [UIView animateWithDuration:.3 animations:^{
                brick.alpha = 0;
            } completion:^(BOOL finished){
                [brick removeFromSuperview];
            }];
            
            // TODO game over because user GOT ALL THE BRICKS
            //            if (bricks.count == 0)
            //            {
            //                // user won!! let them replay?
            //                [self resetBricks];
            
            
            if (bricks.count ==0)
            {
                
                
                [collisionBehavior removeItem:ball];
                [ball removeFromSuperview];
                
                [BABLevelData2 mainData].currentLevel++;
                [self showStartButton];
            }
        }
        
        
    }
}

-(void)createBall
{
    ball = [[UIView alloc] initWithFrame:CGRectMake(paddle.center.x, SCREEN_HEIGHT -50, 20, 20)];
    ball.layer.cornerRadius = ball.frame.size.width/2;
    ball.backgroundColor = [UIColor magentaColor];
    [self.view addSubview:ball];
    
    [ballItemBehavior addItem:ball];
    [collisionBehavior addItem:ball];
    
    UIPushBehavior * pushBehavior = [[UIPushBehavior alloc] initWithItems:@[ball] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(.05, -.05);
    [animator addBehavior:pushBehavior];
    
    
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self movePaddleWithTouchs:touches];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self movePaddleWithTouchs:touches];
}
-(void)movePaddleWithTouchs: (NSSet *) touches
{
    UITouch * touch = [touches allObjects][0];
    CGPoint location = [touch locationInView:self.view];
    
    float guard = paddle.frame.size.width / 2 + 10;
    float dragX = location.x;
    
    if (dragX < guard) dragX = guard;
    if (dragX > SCREEN_WIDTH - guard) dragX = SCREEN_WIDTH - guard;
    
    attachementBehavior.anchorPoint = CGPointMake(location.x, paddle.center.y);
}




-(BOOL) prefersStatusBarHidden {return YES;}



@end
