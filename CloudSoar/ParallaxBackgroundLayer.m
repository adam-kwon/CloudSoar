//
//  ParallaxBackgroundLayer.m
//  Scroller
//
//  Created by min on 4/1/12.
//  Copyright 2012 GAMEPEONS LLC. All rights reserved.
//

#import "ParallaxBackgroundLayer.h"
#import "Constants.h"


@implementation ParallaxBackgroundLayer

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
//    pauseScroll = YES;
    
    veryFirstTime = YES;

    parallaxSpeed = 0.0;
    
    
    scaledScreenWidth = originalScreenSize.width / frontParallax.scale;
    
}

- (id) init {
    if ((self = [super init])) {
        [self setIsTouchEnabled:NO];
        instanceOfLayer = self;
        
        originalScreenSize  = [[CCDirector sharedDirector] winSize];
        
        [self initLayer];
    }
    
    return self;
}

- (void) initLayer {
    // Container to hold the parallax sprites. Used for zooming purposes.
    backParallax = [CCNode node];
    frontParallax = [CCNode node];
    [self addChild:backParallax z:0];
    [self addChild:frontParallax z:2];
    
    earth = [CCSprite spriteWithFile:@"earth.png"];
    earth.anchorPoint = CGPointZero;
    earth.position = ccp(-originalScreenSize.width/3, originalScreenSize.height);

    [self addChild:earth];
    
    [self initParallaxLayers];
    
    // No need to go at full 1/60 cycle.
    //[self schedule:@selector(update:) interval:1.0f/30];
    [self scheduleUpdate];    
}


- (void) setParallaxSpeed:(float)newSpeed {
    parallaxSpeed = newSpeed / 10.f;
    if (parallaxSpeed < 0) {
        parallaxSpeed = 0;
    }
    CCLOG(@"parallax speed = %f", parallaxSpeed);
}


- (void) update:(ccTime)delta {
    if (pauseScroll) {
        return;
    }

    scaledScreenWidth = originalScreenSize.width / frontParallax.scale;
    earth.position = ccp(earth.position.x, earth.position.y-parallaxSpeed);
}

- (void) setZoom:(float)zoom {
    frontParallax.scale = zoom;
    backParallax.scale = zoom;
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

-(void) dealloc {
    CCLOG(@"**** ParallaxBackgroundLayer dealloc");
    [meteors removeAllObjects];
    [meteors release];
    
    [super dealloc];
}


@end
