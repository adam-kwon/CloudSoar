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


@class GameplayLayer;
@class Player;
@class GameObject;
@class SpriteObject;
@class MainGameScene;
@class ParallaxBackgroundLayer;

// HelloWorldLayer
@interface GameplayLayer : CCLayer
{
    MainGameScene                   *mainGameScene;
    ParallaxBackgroundLayer         *parallaxLayer;
    
    CGSize                          screenSize;
    
    NSMutableArray                  *toDeleteArray;

	b2World                         *world;
	GLESDebugDraw                   *m_debugDraw;
    PhysicsWorld                    *physicsWorld;
    
//    CCSprite                        *background;
    
    float                           accelX;
    Player                          *player;
    
    float                           lastEnergyHeight;
    
    float                           _zFactor;
    float                           _oldScale;
    float                           _newScale;
    float                           _zRate;
    float                           _dScale;
    CCNode<GameObject>              *_gameObject;

    b2Body                          *_curBodyNode;
    b2Body                          *_curBodyBackup;
    int                             leadOut;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;
+ (GameplayLayer*) sharedInstance;
- (void) startMainGameLoop;
- (void) initializeGameLayers;
- (void) addToDeleteList:(CCNode<GameObject>*)node;

@property (nonatomic, readonly) Player *player;
@property (nonatomic, readwrite, assign) int leadOut;
@property (nonatomic, readwrite, assign) MainGameScene *mainGameScene;

@end
