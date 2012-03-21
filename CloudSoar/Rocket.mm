//
//  Rocket.m
//  CloudSoar
//
//  Created by Min Kwon on 3/19/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "Rocket.h"
#import "Constants.h"
#import "GameplayLayer.h"
#import "Player.h"

@implementation Rocket

- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectRocket;
	}
	return self;
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
	b2BodyDef playerBodyDef;
	playerBodyDef.type = b2_kinematicBody;
	playerBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	playerBodyDef.userData = self;
	playerBodyDef.fixedRotation = false;
	
	body = theWorld->CreateBody(&playerBodyDef);
	
	b2CircleShape circleShape;
	circleShape.m_radius = ([self boundingBox].size.width/PTM_RATIO)/2;
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circleShape;
	fixtureDef.density = 5000.0f;
	fixtureDef.friction = 3.0f;
	fixtureDef.restitution =  0.18f;
	fixtureDef.isSensor = true;
    //    fixtureDef.filter.categoryBits = CATEGORY_DEFAULT;
    //    fixtureDef.filter.maskBits = CATEGORY_RUNNER;
    //    fixtureDef.filter.groupIndex = 2;
	body->CreateFixture(&fixtureDef);	
}


- (void) destroy {
    CCLOG(@"ROCKET DESTROY");
    lifeState = kLifeStateDead;
    self.visible = NO;
    [self safeToDelete];
    [[GameplayLayer sharedInstance] addToDeleteList:self];
}

- (void) updateObject:(ccTime)dt {
    if (lifeState == kLifeStateDead) {
        return;
    }
    
    Player *player = [GameplayLayer sharedInstance].player;
    float scale = [GameplayLayer sharedInstance].scale;
    
    // Screen is scaled, so how much extra space on left and right of screen
    //float scaledDiff = (screenSize.height/scale - screenSize.width)/2;
    //float bottomEdge = -scaledDiff;
    
    
    if (self.position.y < player.position.y - (screenSize.height/scale/2)) {
        [self destroy];
    }
}


@end
