//
//  FlyThroughBuilding.m
//  CloudSoar
//
//  Created by Min Kwon on 4/5/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "FlyThroughBuilding.h"

@implementation FlyThroughBuilding


- (id) initWithGameplayLayer:(CCLayer*)gameplayLayer {
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
        
        topWindow = [CCSprite spriteWithFile:@"TitleMenuBG.png"];
        topWindow.anchorPoint = CGPointZero;
        topWindow.scaleX = [topBuilding boundingBox].size.width / [topWindow boundingBox].size.width;
        topWindow.scaleY = [topBuilding boundingBox].size.height / [topWindow boundingBox].size.height;
        topWindow.visible = YES;
        topWindow.position = ccp(0, topBuilding.position.y);
        [gameplayLayer addChild:topWindow z:1];

        bottomWindow = [CCSprite spriteWithFile:@"TitleMenuBG.png"];
        bottomWindow.anchorPoint = CGPointZero;
        bottomWindow.scaleX = [bottomBuilding boundingBox].size.width / [bottomWindow boundingBox].size.width;
        bottomWindow.scaleY = [bottomBuilding boundingBox].size.height / [bottomWindow boundingBox].size.height;
        bottomWindow.visible = YES;
        bottomWindow.position = ccp(0, bottomBuilding.position.y);
        [gameplayLayer addChild:bottomWindow z:1];
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
    
    // Two screen height worth of buildings are initially drawn.
    // Keep swapping between the two.
    if (y < -screenSize.height*buildingCount) {
        bottomBuilding.position = ccp(0, topBuilding.position.y + [topBuilding boundingBox].size.height);
        

        bottomWindow.position = ccp(0, topBuilding.position.y + [topBuilding boundingBox].size.height);

        // Swap the top and bottom pointers
        CCSprite *tmp = topBuilding;
        topBuilding = bottomBuilding;
        bottomBuilding = tmp;
        

        tmp = topWindow;
        topWindow = bottomWindow;
        bottomWindow = tmp;
        

        buildingCount++;
    } else if (y > -screenSize.height*(buildingCount-1)) {
        topBuilding.position = ccp(0, bottomBuilding.position.y - [bottomBuilding boundingBox].size.height);

        topWindow.position = ccp(0, bottomBuilding.position.y - [bottomBuilding boundingBox].size.height);

        // Swap the top and bottom pointers
        CCSprite *tmp = topBuilding;
        topBuilding = bottomBuilding;
        bottomBuilding = tmp;
        

        tmp = topWindow;
        topWindow = bottomWindow;
        bottomWindow = tmp;
        
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
