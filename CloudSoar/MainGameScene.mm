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
#import "AudioEngine.h"
#import "AudioConstants.h"

@interface MainGameScene(Private) 
- (void) initStaticBackgroundLayer;
- (void) initGameplayLayer;
- (void) initParallaxBackgroundLayer;
- (void) loadAudio;
@end

@implementation MainGameScene

@synthesize stackBackgroundLayer;
@synthesize parallaxBackgroundLayer;

-(id) init {
	if ((self=[super init])) {
        CCTexture2D *texture;
        
        texture = [[CCTextureCache sharedTextureCache] addImage:@"atlas_default.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"atlas_default.plist" texture:texture];
        [texture setAliasTexParameters];
        
        [self loadAudio];
        
        [self initStaticBackgroundLayer];
        [self initParallaxBackgroundLayer];
        [self initGameplayLayer];
	}
	return self;
}

- (void) loadAudio {
    [[AudioEngine sharedEngine] preloadBackgroundMusic:GAME_MUSIC];
    
    [[AudioEngine sharedEngine] preloadEffect:SND_ENERGY];
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
    [self addChild:gameplayLayer z:-5];
}

- (void) startGameplayLayer {
    [[AudioEngine sharedEngine] playBackgroundMusic:GAME_MUSIC];
    [gameplayLayer initializeGameLayers];
    [gameplayLayer startMainGameLoop];
}

@end
