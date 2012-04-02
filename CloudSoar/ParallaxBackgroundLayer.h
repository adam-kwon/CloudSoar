//
//  ParallaxBackgroundLayer.h
//  Scroller
//
//  Created by min on 4/1/12.
//  Copyright 2012 GAMEPEONS LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"


#define NUM_BACK_PARALLAX_BLDGS         14
#define NUM_FRONT_PARALLAX_BLDGS        5
#define NUM_FRONT_BLDGS_TO_GEN          14
#define NUM_BACK_BLDGS_TO_GEN           NUM_BACK_PARALLAX_BLDGS*4

//#if ZOOM_BACKMOST_PARALLAX
//    #define NUM_BACK_BLDGS_TO_GEN       NUM_BACK_PARALLAX_BLDGS*2
//#else
//    // If back building is not zoomed, better performance can be achieved if the width of the sprite does not exceed screen width
//    #define NUM_BACK_BLDGS_TO_GEN       2
//#endif

#define NUM_BACKGROUND_METEORS 10

@interface ParallaxBackgroundLayer : CCLayer { 
    BOOL        pauseScroll;
    float       parallaxSpeed;                              // Speed at which the parallax layers scroll (set from main game loop)
    CGSize      originalScreenSize;                         // Original screen size before being scaled
    CCNode      *backParallax;                              // CCNode that holds all buildings in the front parallax layer (used as container for zoom purposes)
    CCNode      *frontParallax;                             // CCNode that holds all buildings in the back parallax layer (used as container for zoom purposes) 
    float       scaledScreenWidth;
    CCArray     *meteors;
    BOOL        veryFirstTime;
    CCSprite    *earth;
}

+ (ParallaxBackgroundLayer*) sharedLayer;
- (void) setYOffset:(float)yOffset;
- (void) update:(ccTime) delta;
- (void) setZoom:(float)zoom;
- (void) initParallaxLayers;
- (void) cleanupLayer;
- (void) initLayer;
- (void) setParallaxSpeed:(float)newSpeed;

@property (nonatomic, readwrite, assign) BOOL pauseScroll;
@property (nonatomic, readwrite, assign) CCNode *backParallax;
@property (nonatomic, readwrite, assign) CCNode *frontParallax;

@end
