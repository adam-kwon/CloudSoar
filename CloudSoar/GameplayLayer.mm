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
#import "GPUtil.h"
#import "MainGameScene.h"
#import "ParallaxBackgroundLayer.h"
#import "FlyThroughBuilding.h"

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


@interface GameplayLayer(Private) 
- (void) generateEnergy;
- (void) generateEnergyRandom;
- (void) generateEnergyLine;
- (void) generateEnergyDiamond;
- (void) generateEnergyWave;
- (void) generateEnergyCircle;
- (void) setLastEnergyHeight:(SpriteObject*)energy;
//- (void) zoomOut:(NSNotification*)notifcation;
@end

// HelloWorldLayer implementation
@implementation GameplayLayer

@synthesize player;
@synthesize leadOut;
@synthesize mainGameScene;

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
-(id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {        
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
        self.anchorPoint = CGPointZero;
        
		screenSize = [CCDirector sharedDirector].winSize;
		
        leadOut = screenSize.height/2;
        
        toDeleteArray = [[NSMutableArray alloc] init];
        
        lastEnergyHeight = 0.f;
        
        buildingCount = 1;
        sharedInstance = self;
                
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
		
//        background = [CCSprite spriteWithFile:@"wallpaper.png"];
//        background.anchorPoint = ccp(0.5, 0.5);
//        background.scale = 5.0;
//        background.position = ccp(screenSize.width/2, screenSize.height/2);
//        //bg.rotation = 90;
//        [self addChild:background z:-1];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self 
//                                                 selector:@selector(zoomOut:) 
//                                                     name:ZOOM_OUT_NOTIFICATION object:nil];

        
        player = [Player spriteWithSpriteFrameName:@"Fly-Cycle-2.png"];
        player.position = ccp(160, 20);
        [player createPhysicsObject:world];
        [self addChild:player z:0];

        [self generateEnergy];
        
        flyThroughBuilding = [[[FlyThroughBuilding alloc] initWithGameplayLayer:self] autorelease];
        [self addChild:flyThroughBuilding z:-2];
                
	}
	return self;
}

- (void) startMainGameLoop {
    [self scheduleUpdate];
}

- (void) initializeGameLayers {
    mainGameScene = (MainGameScene*) [self parent];
    parallaxLayer = [mainGameScene parallaxBackgroundLayer];
}

//- (void) zoomOut:(NSNotification*)notifcation {
//    self.scale -= 0.001;
//    background.position = ccp(screenSize.width/self.scale/2, screenSize.height/self.scale/2);
//}

-(void) draw {
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


-(void) update:(ccTime) dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/	

    [physicsWorld step:dt];
    /*
    // Only zoom out when power up is in effect
    if (player.rocketState == kPowerUpStateInEffect) {        
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
        
        [parallaxLayer setZoom:_newScale];
    }
    else if (player.rocketState != kPowerUpStateInEffect && self.scale < 1.0) {
        float newScale = self.scale * (1.0 + (0.2)*dt);
        if (newScale > 1.0) {
            newScale = 1.0;
        }
        self.scale = newScale;
        
        [parallaxLayer setZoom:self.scale];
    }
    */


    [player updateObject:dt withAccelX:accelX gameScale:self.scale];
    [flyThroughBuilding updateObject:dt parentYPosition:self.position.y];
    
    if (fabsf(player.position.y - lastEnergyHeight) < screenSize.height) {
        [self generateEnergy];
    }
    
    [parallaxLayer setParallaxSpeed:[player body]->GetLinearVelocity().y];

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
    
    
    //CCLOG(@"leadout=%d offset=%d", leadOut, leadOutOffSet);
    if (player.position.y > leadOut) {
        // When player's position is above half screen height, start scrolling
        self.position = ccp(self.position.x, -player.position.y * self.scale + (leadOut*self.scale));
    } else {
        self.position = ccp(self.position.x, 0);        
    }

    
    // Clean up. Do physics first then cocos objects    
    CCNode<GameObject, PhysicsObject> *node;
    for (int last = [toDeleteArray count]-1; last >= 0; last--) {
        node = (CCNode<GameObject, PhysicsObject>*)[toDeleteArray objectAtIndex:last];
        if ([node isSafeToDelete]) {
            [toDeleteArray removeObjectAtIndex:last];
            [node destroyPhysicsObject];
            [node removeFromParentAndCleanup:YES];
        }
    }
}

- (void) setLastEnergyHeight:(SpriteObject*)energy {
    if (energy.position.y > lastEnergyHeight) {
        lastEnergyHeight = energy.position.y;
    }
}

- (void) generateEnergyVerticalLine {
    float startY = 60 + lastEnergyHeight;
    
    int col = arc4random() % 280 + 20;
    for (int i = 0; i < 10; i++) {
        SpriteObject *energy;
        energy = [Energy spriteWithSpriteFrameName:@"food.png"];
        energy.position = ccp(col, startY + 50 * i);
        [energy createPhysicsObject:world];
        [self addChild:energy];
        [self setLastEnergyHeight:energy];
    }
}

- (void) generateEnergyRandom {
    float startY = 60 + lastEnergyHeight;
    
    int numRows = 5 + arc4random()%10;
    
    int ySpace = 40+arc4random()%40;
    
    for (int i = 0; i < numRows; i++) {
        SpriteObject *energy;
        int chance = arc4random() % 100;
        if (chance <= 93) {
            energy = [Energy spriteWithSpriteFrameName:@"food.png"];
            energy.position = ccp([GPUtil randomFrom:0 to:screenSize.width/self.scale],  startY + ySpace * i);
            [energy createPhysicsObject:world];
            [self addChild:energy z:-1];
            [self setLastEnergyHeight:energy];
            //            if (arc4random() % 100 < 30) {
            //                int numRepeat = arc4random() % 5;
            //                for (int j = 1; j <= numRepeat; j++) {
            //                    SpriteObject *energy2;
            //                    energy2 = [Energy spriteWithFile:@"food.png"];
            //                    energy2.position = ccp(energy.position.x + [energy boundingBox].size.width * j + 10 + arc4random()%30,  startY + 40 * i + arc4random()%100);
            //                    [energy2 createPhysicsObject:world];
            //                    [self addChild:energy2 z:-1];                
            //                    [self setLastEnergyHeight:energy2];
            //                }
            //            }
        } else {
            energy = [Rocket spriteWithSpriteFrameName:@"food2x.png"];
            energy.position = ccp([GPUtil randomFrom:0 to:screenSize.width/self.scale],  startY + ySpace * i);
            [energy createPhysicsObject:world];
            [self addChild:energy z:-1];             
            [self setLastEnergyHeight:energy];
        }
    }    
    
    [self generateEnergyCircle];
}

- (void) generateEnergyDiamond {
}

- (void) generateEnergyCircle {
    int startX = [GPUtil randomFrom:50 to:screenSize.width/self.scale];
    float startY = lastEnergyHeight;
    
    int radius = 20 + arc4random() % 50;
    
    startY += radius*3;
    
    float thetaDelta;
    
    if (radius > 50) {
        thetaDelta = 0.5;
    } else {
        thetaDelta = 1.0;
    }
    for (float theta = 0; theta < M_PI*2; theta += thetaDelta) {
        SpriteObject *energy = [Energy spriteWithSpriteFrameName:@"food.png"];
        float x = startX + cosf(theta)*radius;
        float y = startY + sinf(theta)*radius;
        energy.position = ccp(x, y);
        [energy createPhysicsObject:world];
        [self addChild:energy z:-1];      
        
        [self setLastEnergyHeight:energy];
    }
}

- (void) generateEnergyWave {
    int startX = [GPUtil randomFrom:50 to:screenSize.width/self.scale];
    float startY = lastEnergyHeight + 50;
    
    int amplitude = 10 + arc4random() % 100;
    
    int doubleHelixChance = arc4random() % 100;
    
    for (float theta = 0; theta < M_PI*2; theta += 0.4) {
        SpriteObject *energy = [Energy spriteWithSpriteFrameName:@"food.png"];
        float x = startX + sinf(theta)*amplitude;
        energy.position = ccp(x, startY);
        [energy createPhysicsObject:world];
        [self addChild:energy z:-1];                        
        [self setLastEnergyHeight:energy];
        if (doubleHelixChance < 50) {
            SpriteObject *energy2;
            x = startX + sinf(theta + M_PI)*amplitude;
            energy2 = [Energy spriteWithSpriteFrameName:@"food.png"];
            energy2.position = ccp(x,  startY);
            [energy2 createPhysicsObject:world];
            [self addChild:energy2 z:-1]; 
            [self setLastEnergyHeight:energy2];
            
        } 
        //        else {
        //            if (arc4random() % 100 < 25) {
        //                int numRepeat = arc4random() % 5;
        //                for (int j = 1; j <= numRepeat; j++) {
        //                    SpriteObject *energy2;
        //                    energy2 = [Energy spriteWithFile:@"food.png"];
        //                    energy2.position = ccp(energy.position.x + [energy boundingBox].size.width * j + 5 + arc4random()%50,  startY);
        //                    [energy2 createPhysicsObject:world];
        //                    [self addChild:energy2 z:-1];                
        //                }        
        //            }
        //        }
        
        startY += [energy boundingBox].size.height + 5;
        
    }
}

- (void) generateEnergy {
    int chance = arc4random() % 100;
    if (chance < 40) {
        [self generateEnergyRandom];
    } else if (chance >= 40 && chance < 70) {
        [self generateEnergyVerticalLine];
    } else if (chance >= 70 && chance < 100) {
        [self generateEnergyWave];
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
	//delete world;
	//world = NULL;
	
	delete m_debugDraw;

    [toDeleteArray removeAllObjects];
    [toDeleteArray release];
    toDeleteArray = nil;

    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
