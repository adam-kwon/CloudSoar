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

@implementation Player
@synthesize state;
@synthesize powerUpState;

- (id) init {
    self = [super init];
    if (self) {
        gameObjectType = kGameObjectPlayer;
        state = kPlayerStateNone;
        powerUpState = kPowerUpStateNone;
        screenSize = [[CCDirector sharedDirector] winSize];
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
	dynamicBox.SetAsBox([self boundingBox].size.width/2/PTM_RATIO,[self boundingBox].size.height/2/PTM_RATIO);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);    
}

- (void) jump {
    // Do jump if not in rocket state
    if (powerUpState != kPowerUpStateInEffect) {
        self.state = kPlayerStateNone;
//        [GameplayLayer sharedInstance].leadOutOffSet = screenSize.height/2;
      
        // Reset the vertical velocity. If not, forces will pile on top each other.
        float yVelocity = body->GetLinearVelocity().y;
        if (yVelocity < 0) {
            yVelocity = 0;
        }
        yVelocity /= 5.0f;
        
        body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, yVelocity));

        body->ApplyLinearImpulse(b2Vec2(0, body->GetMass()*20), body->GetPosition());    

    }
}


- (void) rocket {
    if (powerUpState == kPowerUpStateReceived) {
        state = kPlayerStateNone;
        powerUpState = kPowerUpStateInEffect;
        //[self schedule:@selector(turnOffRocket) interval:5.f];

        float yVelocity = body->GetLinearVelocity().y;
        if (yVelocity < 0) {
            yVelocity = 0;
        }
        yVelocity /= 5.0f;

        // Reset the vertical velocity. If not, forces will pile on top each other.
        body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, yVelocity));
        
        body->ApplyLinearImpulse(b2Vec2(0, body->GetMass()*50), body->GetPosition());    
                
    }
}


- (void) updateObject:(ccTime)dt withAccelX:(float)accelX gameScale:(float)gameScale {
    
    float halfSize = [self boundingBox].size.width/2;
    
    // Screen is scaled, so how much extra space on left and right of screen
    float scaledDiff = (screenSize.width/gameScale - screenSize.width)/2;
    float leftEdge = -scaledDiff;
    float rightEdge = screenSize.width + scaledDiff;

    b2Vec2 pos = body->GetPosition();
    
   // body->SetActive(NO);

    // If going out of view (left or right), make it appear from the opposite side.
    // The entire object must be out of view before reappearing from the opposite side.
    if (self.position.x - halfSize > rightEdge) {
        body->SetTransform(b2Vec2((leftEdge+halfSize+2)/PTM_RATIO + accelX, body->GetPosition().y), 0);
    
    } else if (self.position.x + halfSize < leftEdge) {
        body->SetTransform(b2Vec2((rightEdge-(halfSize+2))/PTM_RATIO + accelX, body->GetPosition().y), 0);
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

    float yVelocity = body->GetLinearVelocity().y;

    //CCLOG(@"%f", body->GetLinearVelocity().y);
    if (powerUpState == kPowerUpStateInEffect) {
        if (yVelocity > 0 && yVelocity < 10) {
            powerUpState = kPowerUpStateCoolDown;
        }
    } 

   // CCLOG(@"yVelocity = %f", yVelocity);

    //CCLOG(@"leadout = %d", [GameplayLayer sharedInstance].leadOut);
    if (yVelocity < -5 || powerUpState == kPowerUpStateCoolDown) {
        [GameplayLayer sharedInstance].leadOut = [GameplayLayer sharedInstance].leadOut - 3;
        if ([GameplayLayer sharedInstance].leadOut <= 160) {
            [GameplayLayer sharedInstance].leadOut = 160;
            powerUpState = kPowerUpStateNone;
        }
    } else if (yVelocity > 20 && powerUpState == kPowerUpStateInEffect) {
        [GameplayLayer sharedInstance].leadOut = [GameplayLayer sharedInstance].leadOut + 5;
        if ([GameplayLayer sharedInstance].leadOut >= 450) {
            [GameplayLayer sharedInstance].leadOut = 450;
        }
    } else if (yVelocity > 10 && powerUpState != kPowerUpStateInEffect) {
        [GameplayLayer sharedInstance].leadOut = [GameplayLayer sharedInstance].leadOut + 3;
        if ([GameplayLayer sharedInstance].leadOut >= 280) {
            [GameplayLayer sharedInstance].leadOut = 280;
        }        
    }
    

    self.position = ccp(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    self.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());


}

@end

