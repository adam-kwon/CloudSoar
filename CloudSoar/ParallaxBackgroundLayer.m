//
//  ParallaxBackgroundLayer.m
//  Scroller
//
//  Created by min on 4/1/12.
//  Copyright 2012 GAMEPEONS LLC. All rights reserved.
//

#import "ParallaxBackgroundLayer.h"
#import "Constants.h"

/*
 * The sprites that make the up parallax layer is pregenerated and their visible property is set to NO so that it is not rendered on screen.
 * Because CCSpriteBatchNode ignores the visible property of its children, it cannot be used. So the sprites are added into a CCNode which 
 * as the container (for zooming purposes). The objects are then scrolled to the left of the screen at a certain rate. Only the sprites that
 * are within the screen's width is set to visible, and the rest are ignored. As the sprite scrolls from right to left and falls off the
 * screen, this sprite's visible property is set to NO and it is repositioned next to the right most sprite for reuse.
 */
@interface ParallaxBackgroundLayer(Private)
- (void) setVisibleBuildings;
@end

@implementation ParallaxBackgroundLayer

@synthesize parallaxSpeed;
@synthesize pauseScroll;
@synthesize backParallax;
@synthesize frontParallax;

const int frontParallax_minGapBetweenBldgs = 20;
const int frontParallax_maxRandGapBetweenBldgs = 45;


static ParallaxBackgroundLayer *instanceOfLayer;

+ (ParallaxBackgroundLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"ParallaxBackgroundLayer instance not yet initialized!");
	return instanceOfLayer;
}

- (void) initParallaxLayers {
    pauseScroll = YES;
    
    veryFirstTime = YES;

    parallaxSpeed = 1.0;
    
    
    scaledScreenWidth = originalScreenSize.width / frontParallax.scale;
    
    [self setVisibleBuildings];   
}

- (id) init {
    if ((self = [super init])) {
        [self setIsTouchEnabled:NO];
        instanceOfLayer = self;
        
        originalScreenSize  = [[CCDirector sharedDirector] winSize];
        
        [self initIntroMeteorSystem];
        [self initLayer];
    }
    
    return self;
}

- (void) initLayer {
    // Container to hold the parallax sprites. Used for zooming purposes.
    backParallax = [CCNode node];
    frontParallax = [CCNode node];
    lastBackParallaxBuilding = nil;
    [self addChild:backParallax z:0];
    [self addChild:frontParallax z:2];
    
    
    [self initParallaxLayers];
    
    // No need to go at full 1/60 cycle.
    //[self schedule:@selector(update:) interval:1.0f/30];
    [self scheduleUpdate];    
}


-(void) setZoom:(float)zoom {
    frontParallax.scale = zoom;
    backParallax.scale = zoom;
}

-(void) dealloc {
    CCLOG(@"**** ParallaxBackgroundLayer dealloc");
    [meteors removeAllObjects];
    [meteors release];

    [super dealloc];
}


-(void) update:(ccTime)delta {
    if (pauseScroll) {
        return;
    }

    scaledScreenWidth = originalScreenSize.width / frontParallax.scale;
    
    BOOL        found = NO;
    CCSprite    *sprite;
    CCSprite    *offScreenSprite = nil;

    // Scroll the back parallax    
    CCARRAY_FOREACH([backParallax children], sprite) {
        CGPoint pos = sprite.position;
 
        // Scroll from right to left in 0.5 pixel increment.
        // If the sprite goes off of the left edge of the screen, then
        // 1. hide it
        // 2. move it after immediately after the last sprite
        
        pos.x -= parallaxSpeed / 3;
        sprite.position = pos;
        
        float bldgWidth = [sprite boundingBox].size.width;
        float rightEdge = pos.x + bldgWidth;
        if (rightEdge < 0.0 && !found) {
            sprite.visible = NO;
            found = YES;
            offScreenSprite = sprite;
        } 
	}
    
    // Do this outside of the loop, because we want to update the position of all sprites first
    // before tacking on the sprite that moved off of the screen onto the end
    if (found) {
        offScreenSprite.position = ccp((lastBackParallaxBuilding.position.x) + [lastBackParallaxBuilding boundingBox].size.width - 2, 
                                       lastBackParallaxBuilding.position.y);                
        lastBackParallaxBuilding = offScreenSprite;

    }
    
    // Scroll the front parallax (scroll speed affected by player's speed)
    found = NO;
	CCARRAY_FOREACH([frontParallax children], sprite) {
        CGPoint pos = sprite.position;

        pos.x -= parallaxSpeed;
        sprite.position = pos;
        
        float bldgWidth = [sprite boundingBox].size.width;
        float rightEdge = pos.x + bldgWidth;
        if (rightEdge < 0.0 && !found) {
            sprite.visible = NO;
            found = YES;
            offScreenSprite = sprite;
        }
	}
    if (found) {
        offScreenSprite.position = ccp(lastFrontParallaxBuilding.position.x
                                            + [lastFrontParallaxBuilding boundingBox].size.width
                                            + frontParallax_minGapBetweenBldgs + rand() % frontParallax_maxRandGapBetweenBldgs, 
                                       lastFrontParallaxBuilding.position.y);
        lastFrontParallaxBuilding = offScreenSprite;        
    }
//     CCLOG(@"----------------------------------> nuMVisible front = %d", [self numVisibleBuildingsOnFrontParallax]);    
    [self setVisibleBuildings];
}

- (void) setYOffset:(float)yOffset {
    self.position = ccp(self.position.x, yOffset);
}


- (void) cleanupLayer {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [frontParallax removeAllChildrenWithCleanup:YES];   // not explicitly needed but whatever
    [backParallax removeAllChildrenWithCleanup:YES];    // not explicitly needed but whatever 
    [self removeChild:frontParallax cleanup:YES];
    [self removeChild:backParallax cleanup:YES];
    frontParallax = nil;
    backParallax = nil;
}

@end
