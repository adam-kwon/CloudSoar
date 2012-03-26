//
//  StaticBackgroundLayer.m
//  CloudSoar
//
//  Created by Min Kwon on 3/21/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"
#import "StaticBackgroundLayer.h"

@interface StaticBackgroundLayer(Private) 
- (void) zoomOut:(NSNotification*)notifcation;
- (void) repositionBackground;
@end

@implementation StaticBackgroundLayer

- (id) init {
    self = [super init];
    if (self) {
        screenSize = [[CCDirector sharedDirector] winSize];
        background = [CCSprite spriteWithFile:@"wallpaper.png"];
        background.anchorPoint = ccp(0.5, 0.5);
        background.scale = 5.0;
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        //bg.rotation = 90;
        [self addChild:background];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(zoomOut:) 
                                                     name:ZOOM_OUT_NOTIFICATION object:nil];
        
        [self schedule:@selector(repositionBackground) interval:1/10];

    }
    
    return self;
}

- (void) repositionBackground {
    background.position = ccp(screenSize.width/self.scale/2, screenSize.height/self.scale/2);    
}

- (void) zoomOut:(NSNotification*)notifcation {
    zoomOutCounter++;
    if (zoomOutCounter >= 20) {
        zoomOutCounter = 0;
        float scale = self.scale * 0.90;
        CCLOG(@"----------> scale = %f", scale);
        //[background stopAllActions];
        [self stopAllActions];
        id scaleTo = [CCScaleTo actionWithDuration:1 scale:scale];
        [self runAction:scaleTo];
        
//        id moveTo = [CCMoveTo actionWithDuration:5 position:ccp(screenSize.width/self.scale/2, screenSize.height/self.scale/2)];
//
//        [background runAction:moveTo];
       // background.position = ccp(screenSize.width/self.scale/2, screenSize.height/self.scale/2);
    }
}

@end
