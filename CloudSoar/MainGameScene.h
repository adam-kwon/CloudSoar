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

@interface MainGameScene : CCScene {
    StaticBackgroundLayer       *staticBackgroundLayer;
    GameplayLayer               *gameplayLayer;
}

@property (nonatomic, readwrite, assign) StaticBackgroundLayer *stackBackgroundLayer;

@end
