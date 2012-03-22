//
//  MainGameScene.m
//  CloudSoar
//
//  Created by Min Kwon on 3/21/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "MainGameScene.h"
#import "StaticBackgroundLayer.h"
#import "GameplayLayer.h"

@interface MainGameScene(Private) 
- (void) initStaticBackgroundLayer;
- (void) initGameplayLayer;
@end

@implementation MainGameScene

@synthesize stackBackgroundLayer;

-(id) init {
	if ((self=[super init])) {
        [self initStaticBackgroundLayer];
        [self initGameplayLayer];
	}
	return self;
}

- (void) initStaticBackgroundLayer {
    staticBackgroundLayer = [StaticBackgroundLayer node];
    [self addChild:staticBackgroundLayer z:-10];
}

- (void) initGameplayLayer {
    gameplayLayer = [GameplayLayer node];
    gameplayLayer.mainGameScene = self;
    [self addChild:gameplayLayer z:-7];
}

@end
