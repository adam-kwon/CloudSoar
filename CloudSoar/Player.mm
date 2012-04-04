//
//  Player.mm
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "Player.h"
#import "GameplayLayer.h"
//#import "AudioEngine.h"

@interface Player(Private)
- (void) setupAnimations;
@end

@implementation Player
@synthesize state;
@synthesize powerUpState;
@synthesize rocketState;

static BOOL animationLoaded;

- (id) init {
    self = [super init];
    if (self) {
        gameObjectType = kGameObjectPlayer;
        state = kPlayerStateNone;
        powerUpState = kPowerUpStateNone;
        rocketState = kPowerUpStateNone;
        screenSize = [[CCDirector sharedDirector] winSize];
        
        rocketParticle = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"rocket.plist"];
        rocketParticle.rotation = -270;
        rocketParticle.position = ccp(rocketParticle.position.x, rocketParticle.position.y+26);
        [self addChild:rocketParticle z:-1];
        [rocketParticle stopSystem];
        rocketParticle.visible = NO;
        
        [self setupAnimations];
        
        id flyAnim = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"flyingAnimation"] restoreOriginalFrame:NO];
        id repeat = [CCRepeatForever actionWithAction:flyAnim];
        [self runAction:repeat];
    }
    return self;
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	bodyDef.userData = self;
	body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(([self boundingBox].size.width-35)/2/PTM_RATIO,[self boundingBox].size.height/2/PTM_RATIO);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	fixture = body->CreateFixture(&fixtureDef);    
    
}

- (void) setupAnimations {
    if (animationLoaded) {
        animationLoaded = YES;
        return;
    }
    
    CCSpriteFrame *frame;
    NSMutableArray *flyFrames = [NSMutableArray array];
    for (int i = 1; i <= 3; i++) {
        NSString *file = [NSString stringWithFormat:@"Fly-Cycle-%d.png", i];
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
        [flyFrames addObject:frame];
    }	
    
    CCAnimation *animFlying = [CCAnimation animationWithFrames:flyFrames delay:0.075];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"flyingAnimation"];
    [[CCAnimationCache sharedAnimationCache] addAnimation:animFlying name:@"flyingAnimation"];            
}

- (void) jump {
    // Do jump if not in rocket state
    if (rocketState != kPowerUpStateInEffect) {
        self.state = kPlayerStateNone;
//        [GameplayLayer sharedInstance].leadOutOffSet = screenSize.height/2;
      
        // Reset the vertical velocity. If not, forces will pile on top each other.
        float yVelocity = body->GetLinearVelocity().y;
        if (yVelocity < 0) {
            yVelocity = 0;
        }
        yVelocity /= 5.0f;

        
//        self.scale *= 0.99;
//        body->DestroyFixture(fixture);
//        b2PolygonShape dynamicBox;
//        dynamicBox.SetAsBox([self boundingBox].size.width/2/PTM_RATIO,[self boundingBox].size.height/2/PTM_RATIO);//These are mid points for our 1m box
//        
//        // Define the dynamic body fixture.
//        b2FixtureDef fixtureDef;
//        fixtureDef.shape = &dynamicBox;	
//        fixtureDef.density = 1.0f;
//        fixtureDef.friction = 0.3f;
//        fixture = body->CreateFixture(&fixtureDef);    
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ZOOM_OUT_NOTIFICATION object:self];

        body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, yVelocity));

        body->ApplyLinearImpulse(b2Vec2(0, body->GetMass()*20), body->GetPosition());    

    }
}


- (void) rocket {
    if (rocketState == kPowerUpStateReceived) {
        state = kPlayerStateNone;
        rocketState = kPowerUpStateInEffect;
        //[self schedule:@selector(turnOffRocket) interval:5.f];

        float yVelocity = body->GetLinearVelocity().y;
        if (yVelocity < 0) {
            yVelocity = 0;
        }
        yVelocity /= 5.0f;

        // Reset the vertical velocity. If not, forces will pile on top each other.
        body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, yVelocity));
        
        body->ApplyLinearImpulse(b2Vec2(0, body->GetMass()*50), body->GetPosition());    
        
        rocketParticle.visible = YES;
        [rocketParticle resetSystem];
    }   
}

- (void) coolDownRocket {
    [self unschedule:@selector(coolDownRocket)];
    rocketState = kPowerUpStateCoolDown;
    rocketParticle.visible = NO;
    [rocketParticle stopSystem];
}

- (void) rocketBoost {
    body->ApplyForce(b2Vec2(0, body->GetMass()*30), body->GetPosition());
    if (!rocketStateCooldownScheduled) {
        rocketStateCooldownScheduled = YES;
        [self schedule:@selector(coolDownRocket) interval:5.0];
    }
}

- (void) updateObject:(ccTime)dt withAccelX:(float)accelX gameScale:(float)gameScale {
    
    float halfSize = [self boundingBox].size.width/2;
    
    // Screen is scaled, anchor point at (0, 0)
//    float scaledDiff = (screenSize.width/gameScale - screenSize.width)/2;
//    float leftEdge = -scaledDiff;
//    float rightEdge = screenSize.width + scaledDiff;

    float rightEdge = screenSize.width / gameScale;

    b2Vec2 pos = body->GetPosition();
    
   // body->SetActive(NO);

    // If going out of view (left or right), make it appear from the opposite side.
    // The entire object must be out of view before reappearing from the opposite side.
    if (self.position.x - halfSize > rightEdge) {
        body->SetTransform(b2Vec2((-halfSize)/PTM_RATIO + accelX, body->GetPosition().y), 0);
    
    } else if (self.position.x + halfSize < 0) {
        body->SetTransform(b2Vec2((rightEdge-(-halfSize))/PTM_RATIO + accelX, body->GetPosition().y), 0);
    } else {
        // Manually move the physics object based on the acceleromter value
        body->SetTransform(b2Vec2(pos.x + accelX, pos.y), 0);
    }

    // Applying physics force based on acceleromter value wasn't very responsive
    // body->ApplyForce(b2Vec2(accelX*50, 0.f), body->GetPosition());

    
//    body->SetActive(YES);

    switch (state) {
        case kPlayerStateGotEnergy:
            [self jump];
            break;
        case kPlayerStateGotRocket:
            [self rocket];
            break;
        default:
            break;
    }

    switch (rocketState) {
        case kPowerUpStateInEffect:
            [self rocketBoost];
            break;
        default:
            break;
    }
    
    float yVelocity = body->GetLinearVelocity().y;

    //CCLOG(@"%f", body->GetLinearVelocity().y);
//    if (powerUpState == kPowerUpStateInEffect) {
//        if (yVelocity > 0 && yVelocity < 10) {
//            powerUpState = kPowerUpStateCoolDown;
//        }
//    } 

   // CCLOG(@"yVelocity = %f", yVelocity);

    //CCLOG(@"leadout = %d", [GameplayLayer sharedInstance].leadOut);
    if (yVelocity < -5 || rocketState == kPowerUpStateCoolDown) {
        [GameplayLayer sharedInstance].leadOut = [GameplayLayer sharedInstance].leadOut - 3;
        if ([GameplayLayer sharedInstance].leadOut <= 160) {
            [GameplayLayer sharedInstance].leadOut = 160;
            rocketState = kPowerUpStateNone;
            rocketStateCooldownScheduled = NO;

        }
    } else if (yVelocity > 20 && rocketState == kPowerUpStateInEffect) {
        [GameplayLayer sharedInstance].leadOut = [GameplayLayer sharedInstance].leadOut + 5;
        if ([GameplayLayer sharedInstance].leadOut >= screenSize.height/gameScale - [self boundingBox].size.height*2) {
            [GameplayLayer sharedInstance].leadOut = screenSize.height/gameScale - [self boundingBox].size.height*2;
        }
    } else if (yVelocity > 10 && rocketState != kPowerUpStateInEffect) {
        [GameplayLayer sharedInstance].leadOut = [GameplayLayer sharedInstance].leadOut + 3;
        if ([GameplayLayer sharedInstance].leadOut >= 280) {
            [GameplayLayer sharedInstance].leadOut = 280;
        }        
    }
    

    self.position = ccp(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    //self.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
}

@end

