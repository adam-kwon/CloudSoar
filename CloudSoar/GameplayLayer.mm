//
//  HelloWorldLayer.mm
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright GAMEPEONS LLC 2012. All rights reserved.
//


// Import the interfaces
#import "GameplayLayer.h"
#import "Constants.h"
#import "Player.h"
#import "Energy.h"
#import "Rocket.h"

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


@interface GameplayLayer(Private) 
- (void) generateEnergy;
@end

// HelloWorldLayer implementation
@implementation GameplayLayer

@synthesize player;

static GameplayLayer *sharedInstance;

+(GameplayLayer*) sharedInstance {
    NSAssert(sharedInstance != nil, @"GameplayLayer instance not initialized");
    return sharedInstance;
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameplayLayer *layer = [GameplayLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		sharedInstance = self;
        
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		screenSize = [CCDirector sharedDirector].winSize;
		
        toDeleteArray = [[NSMutableArray alloc] init];
        
        lastEnergy = nil;
        
		[PhysicsWorld createInstance];
        physicsWorld = [PhysicsWorld sharedWorld];
        world = [physicsWorld getWorld];
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
		
		// Define the ground box shape.
		b2PolygonShape groundBox;		
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(-20,0), b2Vec2(screenSize.width*6/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// top
//		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
//		groundBody->CreateFixture(&groundBox,0);
//		
//		// left
//		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
//		groundBody->CreateFixture(&groundBox,0);
//		
//		// right
//		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
//		groundBody->CreateFixture(&groundBox,0);
		
        
        player = [Player spriteWithFile:@"blocks.png"];
        player.position = ccp(160, 20);
        player.scale = 0.75;
        [player createPhysicsObject:world];
        [self addChild:player];

        [self generateEnergy];
        
		//CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
		//[self addChild:batch z:0 tag:kTagBatchNode];
		
	
        [self scheduleUpdate];
	}
	return self;
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

    glPushMatrix();
    glScalef( CC_CONTENT_SCALE_FACTOR(), CC_CONTENT_SCALE_FACTOR(), 1.0f);
    world->DrawDebugData();
    glPopMatrix();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

- (void) rocketZoomOut {
    CCLOG(@"Rocket Zoom Out");
    id zoomOutAction = [CCScaleTo actionWithDuration:3.0 scale:0.5];
    id zoomInAction = [CCScaleTo actionWithDuration:3.0 scale:1.0];
    id sequence = [CCSequence actions:zoomOutAction, zoomInAction, nil];
//    [self runAction:sequence];
    
    [self runAction:zoomOutAction];  
}

- (void) generateEnergy {
    float startY = 0;
    
    if (lastEnergy != nil) {
        startY = lastEnergy.position.y;
    }
    
    for (int i = 0; i < 10; i++) {
        SpriteObject *energy;
        if (CCRANDOM_0_1() <= 0.9) {
            energy = [Energy spriteWithFile:@"food.png"];
            energy.position = ccp(arc4random() % 320,  startY + 80 * i);
            [energy createPhysicsObject:world];
            [self addChild:energy z:-1];
        } else {
            energy = [Rocket spriteWithFile:@"food2x.png"];
            energy.position = ccp(arc4random() % 320,  startY + 80 * i);
            [energy createPhysicsObject:world];
            [self addChild:energy z:-1];                
        }
        lastEnergy = energy;
    }
    //CCLOG(@"lastEnergy.y = %f", lastEnergy.position.y);
}

-(void) update:(ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/	

    [physicsWorld step:dt];


    if (player.powerUpState == kPowerUpStateInEffect 
        || (player.powerUpState == kPowerUpStateNone && self.scale < 1.0)) {
        float velocity = [player body]->GetLinearVelocity().y / (20);
        
        // Zoom effect
        _zFactor = (ZOOM_OUT_FACTOR) * (velocity);
        _oldScale = self.scale;
        
        // _newScale can become negative. There is no such thing as negative scale.
        // Cocos2d will take the absolute value of scale. So prohibit from becoming too small.
        _newScale = MAX(0.2, ZOOM_FACTOR - _zFactor);
        
        
        _dScale = _oldScale - _newScale;
        _zRate = fabs(_dScale) / dt;        
        
        // hit max zoom rate, throttle the zooming rate
        if (_zRate > ZOOM_RATE) {
            if (_dScale >= 0) {
                // If zooming out
                _newScale = _oldScale - ZOOM_RATE * dt;
            } else { 
                // If zooming in
                _newScale = _oldScale + ZOOM_RATE * dt;
            }
        }
        
        if (_newScale < 1.0) {
            self.scale = _newScale;
        }
    }


    [player updateObject:dt withAccelX:accelX gameScale:self.scale];

    if (fabsf(player.position.y - lastEnergy.position.y) < screenSize.height) {
        [self generateEnergy];
    }

//        if (_newScale > g_rules.max_zoom_out && _newScale <= MAX_ZOOM_IN) {
//            // Synthesized version of scale is set to 'assign', so it doesn't check
//            // if new value is same as old value. So check it explicitly here.
//            if (_newScale != self.scale) {
//                self.scale = _newScale;                
//                _mgs = (MainGameScene*)[self parent];
//                [[ParallaxBackgroundLayer sharedLayer] setZoom:_newScale];
//            }
//        }

    //Iterate over the bodies in the physics world
    _curBodyNode = world->GetBodyList();
    while (_curBodyNode) {
        _curBodyBackup = _curBodyNode;
        _curBodyNode = _curBodyNode->GetNext();
		_gameObject = (CCNode<GameObject>*)_curBodyBackup->GetUserData();
		if (_gameObject != NULL) {
            //if ([_gameObject conformsToProtocol:@protocol(GameObject)]) {
            //    CCLOG(@"-------------------------------------------------------------------------------> %d", [_gameObject gameObjectType]);
            //}
            switch ([_gameObject gameObjectType]) {
                case kGameObjectEnergy:
                case kGameObjectRocket:
                    [_gameObject updateObject:dt];
                    break;
                default:
                    break;
            }            
		}
	}
    
    if (player.position.y > 240) {
        // When player's position is above half screen height, start scrolling
        self.position = ccp(self.position.x, -player.position.y * self.scale + (240*self.scale));
    } else {
        self.position = ccp(self.position.x, 0);        
    }

    
    CCNode<GameObject, PhysicsObject> *node;
    // Clean up. Do physics first then cocos objects
    for (int last = [toDeleteArray count]-1; last >= 0; last--) {
        node = (CCNode<GameObject, PhysicsObject>*)[toDeleteArray objectAtIndex:last];
        if ([node isSafeToDelete]) {
            [toDeleteArray removeObjectAtIndex:last];
            [node destroyPhysicsObject];
            [node removeFromParentAndCleanup:YES];
        }
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [player jump];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
    //	for( UITouch *touch in touches ) {
    //		CGPoint location = [touch locationInView: [touch view]];
    //		
    //		location = [[CCDirector sharedDirector] convertToGL: location];
    //		
    //		[self addNewSpriteWithCoords: location];
    //	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{		
	//#define kFilterFactor 0.05f
	
    //	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
    //	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
    //	
    //	prevX = accelX;
    //	prevY = accelY;
    //	
    //	// accelerometer values are in "Portrait" mode. Change them to Landscape left
    //	// multiply the gravity by 10
    //	b2Vec2 gravity( accelX * 50, -9.8);
    //	
    //	world->SetGravity( gravity );
    
//    accelX = acceleration.x;
    
    accelX = (float) acceleration.x * TILT_SENSITIVITY + (1 - TILT_SENSITIVITY) * accelX;
    
    //    float sensitivity = 10;
    //    
    //    float velocityX = sensitivity * (powf((-fabsf(acceleration.x) + 0.5), 2.0) - 1.25) * -acceleration.x;
    //    float velocityY = sensitivity * (powf((-fabsf(acceleration.y) + 0.5), 2.0) - 1.25) * -acceleration.x;
    //    accelX = velocityX;
    //    CCLOG(@"%f", velocityX);
    //    
    //    if (accelX < -0.5) accelX = -0.25;
    //    else if (accelX > 0.5) accelX = 0.25;
}

- (void) addToDeleteList:(CCNode<GameObject>*)node {
    if (NO == [toDeleteArray containsObject:node]) {
        [toDeleteArray addObject:node];
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;

    [toDeleteArray removeAllObjects];
    [toDeleteArray release];
    toDeleteArray = nil;

    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
