//
//  BABLevelData2.h
//  Bricks and Balls
//
//  Created by Arthur Boia on 8/8/14.
//  Copyright (c) 2014 Arthur Boia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BABLevelData2 : NSObject

+(BABLevelData2*) mainData;

@property (nonatomic) int topScore;
@property (nonatomic) int currentLevel;

- (NSDictionary *) levelInfo;

@end

