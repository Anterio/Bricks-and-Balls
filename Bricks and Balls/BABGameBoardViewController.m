//
//  BABGameBoardViewController.m
//  Bricks and Balls
//
//  Created by Arthur Boia on 8/6/14.
//  Copyright (c) 2014 Arthur Boia. All rights reserved.
//

#import "BABGameBoardViewController.h"

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
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        bricks = [@[]mutableCopy];
        
        
        
        animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        ballItemBehavior = [[UIDynamicItemBehavior alloc] init];
        ballItemBehavior.friction = 0;
        ballItemBehavior.elasticity = 1;
        ballItemBehavior.resistance = 0;
        ballItemBehavior.allowsRotation = NO;
        [animator addBehavior:ballItemBehavior];
        
        brickItemBehavior = [[UIDynamicItemBehavior alloc] init];
        brickItemBehavior.density = 10000000000;
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

   
    
    ball = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -20)/2, SCREEN_HEIGHT -50, 20, 20)];
    ball.layer.cornerRadius = ball.frame.size.width/2;
    ball.backgroundColor = [UIColor magentaColor];
    [self.view addSubview:ball];
    
    
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
            float y = brickSpacing + (height + brickSpacing) * row;
            
            UIView * brick = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            brick.backgroundColor = [UIColor lightGrayColor];
            [self.view addSubview:brick];
            [bricks addObject:brick];
        }
        
        
    }
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    attachementBehavior = [[UIAttachmentBehavior alloc] initWithItem:paddle attachedToAnchor:paddle.center];
    
    [animator addBehavior:attachementBehavior];
    for (UIView * brick in bricks)
    {
        [collisionBehavior addItem:brick];
        [brickItemBehavior addItem:brick];
    }
    
    [collisionBehavior addItem:ball];
    UIPushBehavior * pushBehavior = [[UIPushBehavior alloc] initWithItems:@[ball] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(.1, -.1);
    [animator addBehavior:pushBehavior];
    [ballItemBehavior addItem:ball];
    [collisionBehavior addItem:paddle];
    [brickItemBehavior addItem:paddle];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if ([@"floor" isEqualToString:(NSString *)identifier])
    {
        UIView * ballItem = (UIView *) item;
        [collisionBehavior removeItem:ballItem];
        [ballItem removeFromSuperview];
    }
    
    
}
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    for (UIView * brick in [bricks copy])
    {
        if ([item1 isEqual:brick] || [item2 isEqual:brick])
        {
            [collisionBehavior removeItem:brick];
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
    
 //   paddle.center = CGPointMake(location.x, paddle.center.y);
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(BOOL) prefersStatusBarHidden {return YES;}



@end
