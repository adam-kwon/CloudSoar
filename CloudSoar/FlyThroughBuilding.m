//
//  FlyThroughBuilding.m
//  CloudSoar
//
//  Created by Min Kwon on 4/5/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "FlyThroughBuilding.h"

@implementation FlyThroughBuilding


- (id) init {
    self = [super init];
    if (self) {
        gameObjectType = kGameObjectFlyThroughBuilding;

        screenSize = [[CCDirector sharedDirector] winSize];
        buildingCount = 1;
        
        bottomBuilding = [CCSprite spriteWithFile:@"Flythrough.png"];
        bottomBuilding.anchorPoint = CGPointZero;
        bottomBuilding.position = ccp(0, 0);
        [self addChild:bottomBuilding z:-2];
        
        topBuilding = [CCSprite spriteWithFile:@"Flythrough.png"];
        topBuilding.anchorPoint = CGPointZero;
        topBuilding.position = ccp(0, [bottomBuilding boundingBox].size.height);
        [self addChild:topBuilding z:-2];        
    }
    
    return self;
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}


- (void) safeToDelete {
    isSafeToDelete = YES;
}

- (GameObjectType) gameObjectType {
    return gameObjectType;
}

- (void) updateObject:(ccTime)dt parentYPosition:(float)y {
    //CGPoint pos = [self.parent convertToWorldSpace:self.position];
    if (y < -screenSize.height*buildingCount) {
        bottomBuilding.position = ccp(0, topBuilding.position.y + [topBuilding boundingBox].size.height);
        
        //        CCSprite *window = [CCSprite spriteWithFile:@"TitleMenuBG.png"];
        //        window.anchorPoint = ccp(0, 0);
        //        window.position = ccp(0, bottomBuilding.position.y + [bottomBuilding boundingBox].size.height/2);
        //        window.scaleX = [bottomBuilding boundingBox].size.width / [window boundingBox].size.width;
        //        [self addChild:window z:1];
        
        // Swap the top and bottom pointers
        CCSprite *tmp = topBuilding;
        topBuilding = bottomBuilding;
        bottomBuilding = tmp;
        
        
        
        buildingCount++;
    } else if (y > -screenSize.height*(buildingCount-1)) {
        CCLOG(@"self.y=%f  bottom.y=%f", self.position.y, bottomBuilding.position.y);
        topBuilding.position = ccp(0, bottomBuilding.position.y - [bottomBuilding boundingBox].size.height);
        
        // Swap the top and bottom pointers
        CCSprite *tmp = topBuilding;
        topBuilding = bottomBuilding;
        bottomBuilding = tmp;
        
        buildingCount--;
    }    
}

- (void) updateObject:(ccTime)dt {
    
}

- (CGRect) boundingBox {
//    return [building boundingBox];
}

- (void) dealloc {
    [super dealloc];
}

@end
