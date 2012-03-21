//
//  Constants.h
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#ifndef cloudjump_Constants_h
#define cloudjump_Constants_h

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

#define ZOOM_FACTOR		1.30193f                                            // Default zoom 1:1
//#define ZOOM_FACTOR             1                                         // Default zoom is around 0.7
#define ZOOM_OUT_FACTOR         0.3f                                        // Zoom out factor (used in conjunction with ZOOM_RATE)
#define ZOOM_OUT_FACTOR_HEIGHT  0.00070                                     // How much to zoom out as height of player changes

#define SMOOTH_ZOOM             1                                           // Use smooth zoom
#define ZOOM_RATE               0.40 // pixels/sec                          // Zoom rate (depends on ZOOM_OUT_FACTOR)
#define MAX_ZOOM_OUT            0.3f                                        // Will not zoom out past this point
#define MAX_ZOOM_IN             0.75                                        // Will not zoom in past this point

#define TILT_SENSITIVITY        0.15                                        // Bigger value is more sensitive

// Define game object types here
typedef enum {
	kGameObjectNone,                            // 0
    kGameObjectPlayer,
    kGameObjectEnergy,
    kGameObjectRocket
} GameObjectType;

typedef enum {
    kLifeStateNone,
    kLifeStateAlive,
    kLifeStateDead
} LifeState;

typedef enum {
    kGameObjectStateNone,
    kGameObjectStateDestroy
} GameObjectState;

#endif
