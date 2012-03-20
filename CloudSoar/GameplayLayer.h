//
//  HelloWorldLayer.h
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright GAMEPEONS, LLC 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "PhysicsWorld.h"

@class Player;
@class SpriteObject;

// HelloWorldLayer
@interface GameplayLayer : CCLayer
{
    CGSize          screenSize;
    
	b2World         *world;
	GLESDebugDraw   *m_debugDraw;
    PhysicsWorld    *physicsWorld;
    
    float           accelX;
    Player          *player;
    
    SpriteObject    *lastEnergy;
    
    float           _zFactor;
    float           _oldScale;
    float           _newScale;
    float           _zRate;
    float           _dScale;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;

- (void) rocketZoomOut;

@end
