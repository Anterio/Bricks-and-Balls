//
//  BABGameBoardViewController.m
//  Bricks and Balls
//
//  Created by Arthur Boia on 8/6/14.
//  Copyright (c) 2014 Arthur Boia. All rights reserved.
//

#import "BABGameBoardViewController.h"


//after you hit floor start new ball and take away one life
//once all 3 lives are lost game over alert, with option to restart (should reset life count)

//score count, bricks broken add points to score count
//create temporary label for score count

@interface BABGameBoardViewController () <UICollisionBehaviorDelegate>

@end

@implementation BABGameBoardViewController
{
    UIDynamicAnimator * animator;
    UIDynamicItemBehavior * ballItemBehavior;
    UIDynamicItemBehavior * brickItemBehavior;
    UICollisionBehavior * collisionBehavior;
    UIView * ball;
    UIView * paddle;
    UIGravityBehavior * gravityBehavior;
    UIAttachmentBehavior * attachementBehavior;
    NSMutableArray * bricks;
    UILabel * livesLabel;
    UILabel * scoreLabel;
    UIView * ballItem;
    UIView * brick;
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
        gravityBehavior.gravityDirection = CGVectorMake(0, 5);
        [animator addBehavior:gravityBehavior];
        
        collisionBehavior = [[UICollisionBehavior alloc] init];
        collisionBehavior.collisionDelegate = self;
        
//        collisionBehavior.translatesReferenceBoundsIntoBoundary =YES;
        [collisionBehavior addBoundaryWithIdentifier:@"floor" fromPoint:CGPointMake(0, SCREEN_HEIGHT+20) toPoint:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT+20)];
        [collisionBehavior addBoundaryWithIdentifier:@"leftwall" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, SCREEN_HEIGHT)];
        [collisionBehavior addBoundaryWithIdentifier:@"ceiling" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(SCREEN_WIDTH, 0)];
        [collisionBehavior addBoundaryWithIdentifier:@"rightwall" fromPoint:CGPointMake(SCREEN_WIDTH, 0) toPoint:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        [animator addBehavior:collisionBehavior];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    paddle = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -100 )/2, SCREEN_HEIGHT -10, 100, 4)];
    paddle.backgroundColor = [UIColor blackColor];
    [self.view addSubview:paddle];

    startButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, (SCREEN_HEIGHT-100)/2, 100, 100)];
    [startButton setTitle:@"START" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    startButton.backgroundColor = [UIColor lightGrayColor];
    
    livesLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 205, 80, 30)];
    livesLabel.backgroundColor = [UIColor lightGrayColor];
    livesLabel.layer.cornerRadius = 5;
    livesLabel.layer.masksToBounds = YES;
    livesLabel.textColor = [UIColor greenColor];
    livesLabel.text = [NSString stringWithFormat:@" Lives %d", headerView.lives];
    livesLabel.font = [UIFont systemFontOfSize:15];                      // <-- HEIDI THINKS ITS UGLY u decide
    
    [self.view addSubview:livesLabel];
    
    
    scoreLabel= [[UILabel alloc] initWithFrame:CGRectMake(5, 165, 80, 30)];
    scoreLabel.backgroundColor = [UIColor lightGrayColor];
    scoreLabel.layer.cornerRadius = 5;
    scoreLabel.layer.masksToBounds = YES;
    scoreLabel.textColor = [UIColor greenColor];
    scoreLabel.text = [NSString stringWithFormat:@" Score %d", headerView.score];
    [self.view addSubview:scoreLabel];
    scoreLabel.font = [UIFont systemFontOfSize:15];
    
    
    NSLog (@"%d", headerView.lives);
    

    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    attachementBehavior = [[UIAttachmentBehavior alloc] initWithItem:paddle attachedToAnchor:paddle.center];
    [animator addBehavior:attachementBehavior];
   
    [collisionBehavior addItem:paddle];
    [brickItemBehavior addItem:paddle];

}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if ([@"floor" isEqualToString:(NSString *)identifier])
    {
        ballItem = (UIView *) item;
        [collisionBehavior removeItem:ballItem];
                NSLog(@"%d", headerView.lives);
        livesLabel.text = [NSString stringWithFormat:@" Lives %d", headerView.lives];
        
        [ballItem removeFromSuperview];
        
        ball = nil;
        
        if (headerView.lives > 0)
        {
            headerView.lives = headerView.lives-1;
            [self createBall];
        }
        else
        {
            // game over
            if (bricks.count == 0)
            {
                // user won!! let them replay?
                [self resetBricks];
            }
            else
            {
                UIAlertView * youIsDead=[[UIAlertView alloc] initWithTitle:@"You is Dead" message:@"And you suck" delegate:self cancelButtonTitle:@"Play Again" otherButtonTitles: nil];
                [youIsDead show];
            }

        }

    }
    
    
}
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    for (brick in [bricks copy])
    {
        if ([item1 isEqual:brick] || [item2 isEqual:brick])
        {
            headerView.score +=100;
            [collisionBehavior removeItem:brick];
            scoreLabel.text = [NSString stringWithFormat:@" Score %d", headerView.score];
            [gravityBehavior addItem:brick];
            [bricks removeObjectIdenticalTo:brick];
            [UIView animateWithDuration:.3 animations:^{
                
                brick.alpha = 0;
                
                
            } completion:^(BOOL finished){
                [brick removeFromSuperview];
                [bricks removeObjectIdenticalTo:brick];
            }];
        
        }
    }
}
-(void) startGame
{
    [startButton removeFromSuperview];
    [self resetBricks];
    [self createBall];
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

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (headerView.lives == 0)
    {
        headerView.lives = 3;
        livesLabel.text = [NSString stringWithFormat:@" Lives %d", headerView.lives];
        headerView.score = 0;
        scoreLabel.text = [NSString stringWithFormat:@" Score %d", headerView.score];

        [self startGame];
    }
}

-(void)createBall
{
    ball = [[UIView alloc] initWithFrame:CGRectMake(paddle.center.x, SCREEN_HEIGHT -50, 20, 20)];
    ball.layer.cornerRadius = ball.frame.size.width/2;
    ball.backgroundColor = [UIColor magentaColor];
    [self.view addSubview:ball];
//    NSLog(@"", collisionBehavior);
    
    UIPushBehavior * pushBehavior = [[UIPushBehavior alloc] initWithItems:@[ball] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(.05, -.05);
    [animator addBehavior:pushBehavior];
    [pushBehavior addItem:ball];
    [ballItemBehavior addItem:ball];
    [collisionBehavior addItem:ball];
}


-(void)resetBricks
{
    
    for (brick in bricks)
    {
        [brick removeFromSuperview];
        [brickItemBehavior removeItem:brick];
        [collisionBehavior removeItem:brick];
    }
    
    [bricks removeAllObjects];
    
    int colCount = 7;
    int rowCount = 4;
    int brickSpacing = 8;
    
    for (int col = 0; col < colCount; col++)
    {
        for (int row = 0; row < rowCount; row++)
        {
            float width = (SCREEN_WIDTH - (brickSpacing*(colCount+1)))/colCount;
            float height = ((SCREEN_HEIGHT/3) - (brickSpacing*rowCount))/rowCount;
            
            float x = brickSpacing + (width + brickSpacing) * col;
            float y = brickSpacing + (height + brickSpacing) * row +30;
            
            brick = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            
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
- (void)updateItemUsingCurrentState:(id<UIDynamicItem>)item
{
    
}
-(BOOL) prefersStatusBarHidden {return YES;}



@end
