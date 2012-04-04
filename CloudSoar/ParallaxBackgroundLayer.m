//
//  ParallaxBackgroundLayer.m
//  Scroller
//
//  Created by min on 4/1/12.
//  Copyright 2012 GAMEPEONS LLC. All rights reserved.
//

#import "ParallaxBackgroundLayer.h"
#import "Constants.h"
#import "GPUtil.h"

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
        self.anchorPoint = CGPointZero;
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

    CCSprite *earth = [CCSprite spriteWithFile:@"earth.png"];
    earth.scale = 2.0f;
    earth.anchorPoint = CGPointZero;
    earth.position = ccp(-[earth boundingBox].size.width/2, originalScreenSize.height);
    [backParallax addChild:earth];

//    CCSprite *moon = [CCSprite spriteWithFile:@"moon.png"];
//    moon.anchorPoint = CGPointZero;
//    moon.position = ccp(earth.position.x + [earth boundingBox].size.width, originalScreenSize.height);
//    [backParallax addChild:moon];


    CCSprite *stars1 = [CCSprite spriteWithSpriteFrameName:@"stars1.png"];
    stars1.anchorPoint = CGPointZero;
    stars1.position = ccp([GPUtil randomFrom:[stars1 boundingBox].size.width to:originalScreenSize.width/3], 
                          originalScreenSize.height + [stars1 boundingBox].size.height);
    [frontParallax addChild:stars1];
    
    CCSprite *stars2 = [CCSprite spriteWithSpriteFrameName:@"stars1.png"];
    stars2.anchorPoint = CGPointZero;
    stars2.flipX = YES;
    stars2.position = ccp([GPUtil randomFrom:stars1.position.x+[stars1 boundingBox].size.width to:originalScreenSize.width-[stars1 boundingBox].size.width], 
                          stars1.position.y + arc4random()%50);
    [frontParallax addChild:stars2];

    CCSprite *stars3 = [CCSprite spriteWithSpriteFrameName:@"stars1.png"];
    stars3.anchorPoint = CGPointZero;
    stars3.flipY = YES;
    stars3.position = ccp([GPUtil randomFrom:[stars3 boundingBox].size.width to:originalScreenSize.width-[stars3 boundingBox].size.width],
                          stars2.position.y+[stars2 boundingBox].size.height+arc4random()%((int)originalScreenSize.height));
    [frontParallax addChild:stars3];


    CCSprite *galaxy = [CCSprite spriteWithSpriteFrameName:@"galaxy.png"];
    galaxy.position = ccp([GPUtil randomFrom:0 to:originalScreenSize.width-[galaxy boundingBox].size.width], 
                          stars3.position.y + [GPUtil randomFrom:originalScreenSize.height to:originalScreenSize.height*2]);
    [frontParallax addChild:galaxy];

    [self initParallaxLayers];
    
    // No need to go at full 1/60 cycle.
    //[self schedule:@selector(update:) interval:1.0f/30];
    [self scheduleUpdate];    
}


- (void) setParallaxSpeed:(float)newSpeed {
    parallaxSpeed = newSpeed / 200.f;
    frontParallaxSpeed = newSpeed / 10.f;
    if (parallaxSpeed < 0) {
        parallaxSpeed = 0;
    }
//    CCLOG(@"parallax speed = %f", parallaxSpeed);
}


- (void) update:(ccTime)delta {
    if (pauseScroll) {
        return;
    }

    scaledScreenWidth = originalScreenSize.width / backParallax.scale;
    scaledScreenHeight = originalScreenSize.height / backParallax.scale;
    
    CCSprite *sprite;

    CCARRAY_FOREACH([backParallax children], sprite) {
        CGPoint pos = sprite.position;
        
        pos.y -= parallaxSpeed;
        if (pos.y <= scaledScreenHeight - [sprite boundingBox].size.height) {
            pos.y = scaledScreenHeight - [sprite boundingBox].size.height;
        }
        
        sprite.position = pos;
    }

    CCARRAY_FOREACH([frontParallax children], sprite) {
        CGPoint pos = sprite.position;
        
        pos.y -= frontParallaxSpeed;
        if (pos.y < -[sprite boundingBox].size.height) {
            pos = ccp([GPUtil randomFrom:[sprite boundingBox].size.width to:originalScreenSize.width-[sprite boundingBox].size.width],
                      [GPUtil randomFrom:originalScreenSize.height to:originalScreenSize.height*2]);
        }
        
        sprite.position = pos;
    }
    
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
    
    [super dealloc];
}


@end
