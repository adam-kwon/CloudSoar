//
//  MainGameScene.h
//  CloudSoar
//
//  Created by Min Kwon on 3/21/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "CCScene.h"

@class StaticBackgroundLayer;
@class GameplayLayer;
@class ParallaxBackgroundLayer;

@interface MainGameScene : CCScene {
    StaticBackgroundLayer       *staticBackgroundLayer;
    ParallaxBackgroundLayer     *parallaxBackgroundLayer;
    GameplayLayer               *gameplayLayer;
}

- (void) startGameplayLayer;

@property (nonatomic, readwrite, assign) StaticBackgroundLayer *stackBackgroundLayer;
@property (nonatomic, readwrite, assign) ParallaxBackgroundLayer *parallaxBackgroundLayer;

@end
