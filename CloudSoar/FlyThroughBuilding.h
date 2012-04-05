//
//  FlyThroughBuilding.h
//  CloudSoar
//
//  Created by Min Kwon on 4/5/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "GameObject.h"

@interface FlyThroughBuilding : CCNode<GameObject> {
    BOOL isSafeToDelete;
    GameObjectType gameObjectType;
    CGSize screenSize;
    int buildingCount;
    CCSprite *topBuilding;
    CCSprite *bottomBuilding;
    CCSprite *buildingWindow;
}

- (CGRect) boundingBox;

- (void) updateObject:(ccTime)dt parentYPosition:(float)y;
//@property (nonatomic, readwrite, assign) CCSprite *building;
//@property (nonatomic, readwrite, assign) CCSprite *buildingWindow;

@end
