//
//  Player.h
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "PhysicsObject.h"
#import "SpriteObject.h"
#import "AudioEngine.h"

typedef enum {
    kPlayerStateNone,
    kPlayerStateGotEnergy,
    kPlayerStateGotRocket
} PlayerState;

typedef enum {
    kPowerUpStateNone,
    kPowerUpStateReceived,
    kPowerUpStateInEffect,
    kPowerUpStateCoolDown,
    kPowerUpStateDone
} PowerUpState;

@interface Player : SpriteObject {
    PlayerState state;
    PowerUpState powerUpState;
    
    CCParticleSystem *rocketParticle;
    
    PowerUpState rocketState;
    BOOL rocketStateCooldownScheduled; 
    
    ALuint windFx;
}

- (void) rocket;
- (void) jump;
- (void) updateObject:(ccTime)dt withAccelX:(float)accelX gameScale:(float)gameScale;

@property (nonatomic, readwrite, assign) PlayerState state;
@property (nonatomic, readwrite, assign) PowerUpState powerUpState;
@property (nonatomic, readwrite, assign) PowerUpState rocketState;
@end
