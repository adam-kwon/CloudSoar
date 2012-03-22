//
//  StaticBackgroundLayer.h
//  CloudSoar
//
//  Created by Min Kwon on 3/21/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "cocos2d.h"

@interface StaticBackgroundLayer : CCNode {
    CCSprite    *background;
    CGSize      screenSize;
    int         zoomOutCounter;
}

@end
