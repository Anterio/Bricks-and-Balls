//
//  BABLevelData2.m
//  Bricks and Balls
//
//  Created by Arthur Boia on 8/8/14.
//  Copyright (c) 2014 Arthur Boia. All rights reserved.
//

#import "BABLevelData2.h"

@implementation BABLevelData2
{
    NSArray * levels;
}

+ (BABLevelData2*) mainData
{
    static dispatch_once_t create;
    
    static BABLevelData2 * singleton = nil;
    
    dispatch_once(&create, ^{
     
        singleton = [[BABLevelData2 alloc] init];
        
        
    });
    
    return singleton;
    
}

- (id) init
{
    self = [super init];
    if (self)
    {
         levels = @[
                       @{
                        @"cols" : @1,
                        @"rows" : @4,
                        },
                       @{
                           @"cols" : @4,
                           @"rows" : @3,
                           },
                       @{
                           @"cols" : @10,
                           @"rows" : @4,
                           },
                    ];
    }
    return self;
}

- (NSDictionary *) levelInfo;
{
    return  levels[self.currentLevel];
}


@end