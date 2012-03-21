//
//  Player.h
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "PhysicsObject.h"
#import "SpriteObject.h"

typedef enum {
    kPlayerStateNone,
    kPlayerStateGotEnergy,
    kPlayerStateGotRocket
} PlayerState;

typedef enum {
    kPowerUpStateNone,
    kPowerUpStateReceived,
    kPowerUpStateInEffect,
    kPowerUpStateDone
} PowerUpState;

@interface Player : SpriteObject {
    PlayerState state;
    PowerUpState powerUpState;
}

- (void) rocket;
- (void) jump;
- (void) updateObject:(ccTime)dt withAccelX:(float)accelX gameScale:(float)gameScale;

@property (nonatomic, readwrite, assign) PlayerState state;
@property (nonatomic, readwrite, assign) PowerUpState powerUpState;
@end
