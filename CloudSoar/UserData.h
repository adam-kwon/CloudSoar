//
//  UserData.h
//  Scroller
//
//  Created by min on 3/26/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "DeviceDetection.h"
#import "Constants.h"
#import <MediaPlayer/MediaPlayer.h>

typedef enum {
    kPerformanceNone,
    kPerformanceLow,
    kPerformanceMedium,
    kPerformanceHigh
} PerformanceProfile;

@interface UserData : NSObject {
    float                   fxVolumeLevel;
    float                   musicVolumeLevel;
    DeviceType              device;
    PerformanceProfile      profile;
    MPMediaItemCollection   *playList;
    
    BOOL                    isCustomMusic;
    BOOL                    reduceVolume;
    NSDate                  *date;
    NSString                *gameVersion;
    NSString                *deviceId;
}

+ (UserData*) sharedInstance;
- (void) readOptionsFromDisk;
- (void) persist;
- (void) savePlayList:(MPMediaItemCollection*)collection;
- (void) loadPlayList;

@property (nonatomic, readwrite, assign) NSDate *date;
@property (nonatomic, readwrite, assign) MPMediaItemCollection *playList;
@property (nonatomic, readwrite, assign) BOOL reduceVolume;
@property (nonatomic, readwrite, assign) float musicVolumeLevel;
@property (nonatomic, readwrite, assign) float fxVolumeLevel;
@property (nonatomic, readwrite, assign) DeviceType device;
@property (nonatomic, readwrite, assign) PerformanceProfile profile;
@property (nonatomic, readwrite, assign) BOOL isCustomMusic;
@property (nonatomic, readwrite, assign) NSString *gameVersion;
@property (nonatomic, readwrite, retain) NSString *deviceId;

@end
