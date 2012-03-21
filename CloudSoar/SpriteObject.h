//
//  SpriteObject.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 11/16/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "Constants.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "PhysicsObject.h"
#import "GameObject.h"

@class GameScene;

@interface SpriteObject : CCSprite<PhysicsObject, GameObject> {    
	GameObjectType			gameObjectType;
    GameObjectState         gameObjectState;
    LifeState               lifeState;
	b2World					*world;
	b2Body					*body;
    BOOL                    isSafeToDelete;
    CGSize                  screenSize;
}

- (void) updateObject:(ccTime)dt;
- (void) safeToDelete;

@property (nonatomic, readwrite, assign) LifeState lifeState;
@property (nonatomic, readwrite, assign) GameObjectType gameObjectType;
@property (nonatomic, readwrite, assign) GameObjectState gameObjectState;
@property (nonatomic, readonly) b2Body *body;

@end
