//
//  MainGameScene.m
//  CloudSoar
//
//  Created by Min Kwon on 3/21/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "MainGameScene.h"
#import "StaticBackgroundLayer.h"
#import "ParallaxBackgroundLayer.h"
#import "GameplayLayer.h"

@interface MainGameScene(Private) 
- (void) initStaticBackgroundLayer;
- (void) initGameplayLayer;
- (void) initParallaxBackgroundLayer;
@end

@implementation MainGameScene

@synthesize stackBackgroundLayer;
@synthesize parallaxBackgroundLayer;

-(id) init {
	if ((self=[super init])) {
        [self initStaticBackgroundLayer];
        [self initParallaxBackgroundLayer];
        [self initGameplayLayer];
	}
	return self;
}

- (void) initParallaxBackgroundLayer {
    parallaxBackgroundLayer = [ParallaxBackgroundLayer node];
    [self addChild:parallaxBackgroundLayer z:-7];
}

- (void) initStaticBackgroundLayer {
    staticBackgroundLayer = [StaticBackgroundLayer node];
    [self addChild:staticBackgroundLayer z:-10];
}

- (void) initGameplayLayer {
    gameplayLayer = [GameplayLayer node];
    [gameplayLayer initializeGameLayers];
    [gameplayLayer startMainGameLoop];
    [self addChild:gameplayLayer z:-5];
}

@end
