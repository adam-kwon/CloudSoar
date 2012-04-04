//
//  UserData.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 6/13/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "UserData.h"
#import "Constants.h"

#define PER_KEY_FX_VOLUME                                       @"2012ASC_1"
#define PER_KEY_MUSIC_VOLUME                                    @"2012ASC_2"
#define PER_KEY_CUSTOM_MUSIC                                    @"2012ASC_3"
#define PER_KEY_PLAYLIST                                        @"2012ASC_4"
#define PER_KEY_GAME_VERSION                                    @"2012ASC_5"
#define PER_KEY_DEVICE_ID                                       @"2012ASC_6"

@interface UserData(Private)
@end

@implementation UserData
@synthesize device;
@synthesize profile;
@synthesize isCustomMusic;
@synthesize fxVolumeLevel;
@synthesize musicVolumeLevel;
@synthesize reduceVolume;
@synthesize playList;
@synthesize gameVersion;
@synthesize date;
@synthesize deviceId;

static UserData *sharedInstance;

+ (UserData*) sharedInstance {
	NSAssert(sharedInstance != nil, @"UserData instance not yet initialized!");
	return sharedInstance;
}

- (void) dealloc {
    [super dealloc];
}


- (id)init {
    if ((self = [super init])) {
        sharedInstance = self;
        reduceVolume = NO;
    }
    
    return self;
}

- (void) persist {
    if (isCustomMusic) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:PER_KEY_CUSTOM_MUSIC];            
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:PER_KEY_CUSTOM_MUSIC];            
    }


    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", deviceId] forKey:PER_KEY_DEVICE_ID];            

    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", fxVolumeLevel] forKey:PER_KEY_FX_VOLUME];            
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", musicVolumeLevel] forKey:PER_KEY_MUSIC_VOLUME];     
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) savePlayList:(MPMediaItemCollection *)collection {
    NSArray *items = [collection items];
    NSMutableArray *listToSave = [NSMutableArray arrayWithCapacity:1];
    int i = 0;
    for (MPMediaItem *song in items) {
        if (i++ > 20) {
            break;
        }
        NSNumber *persistentId = [song valueForProperty:MPMediaItemPropertyPersistentID];
        [listToSave addObject:persistentId];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:listToSave];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:PER_KEY_PLAYLIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadPlayList {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:PER_KEY_PLAYLIST];
    if (nil != data) {
        NSMutableArray *theList = [NSMutableArray arrayWithCapacity:1];
        NSArray *decodedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [theList addObjectsFromArray:decodedData];
        NSMutableArray *allTheSongs = [NSMutableArray arrayWithCapacity:1];
        for (int i = 0; i < [theList count]; i++) {
            MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
            [songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[theList objectAtIndex:i] forProperty:MPMediaItemPropertyPersistentID]];
            NSArray *songs = [songQuery items];
            [allTheSongs addObjectsFromArray:songs];
        }
        //playList = [[MPMediaItemCollection alloc] initWithItems:allTheSongs];
        if (nil != allTheSongs && [allTheSongs count] > 0) {
            playList = [MPMediaItemCollection collectionWithItems:allTheSongs];
        }

    } else {
        playList = nil;
    }    
}

- (BOOL) getBOOL:(NSString*)key {
    BOOL r = NO;
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str != nil) {
        if ([@"YES" isEqualToString:str]) {
            r = YES;
        }
    }
    return r;
}

- (float) getFloat:(NSString*)key withDefault:(float)d {
    float v;
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str == nil) {
        v = d;
    } else {
        v = [str floatValue];
    }
    return v;
}

- (float) getInt:(NSString*)key withDefault:(int)d {
    int v;
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str == nil) {
        v = d;
    } else {
        v = [str intValue];
    }
    return v;
}

- (NSString*) getNSString:(NSString*)key {
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str == nil) {
        str = [DeviceDetection uuid];
    }
    
    return str;
}

- (float) getUnsignedLong:(NSString*)key withDefault:(unsigned long)d {
    unsigned long v;
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str == nil) {
        v = d;
    } else {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        v = [[formatter numberFromString:str] unsignedLongValue];
        [formatter release];
    }
    return v;
}


- (void) readOptionsFromDisk {
    gameVersion = [[NSUserDefaults standardUserDefaults] objectForKey:PER_KEY_GAME_VERSION];
        
    self.deviceId = [self getNSString:PER_KEY_DEVICE_ID];
    isCustomMusic = [self getBOOL:PER_KEY_CUSTOM_MUSIC];
    fxVolumeLevel = [self getFloat:PER_KEY_FX_VOLUME withDefault:1.0f];
    musicVolumeLevel = [self getFloat:PER_KEY_MUSIC_VOLUME withDefault:0.5f];
    
    device = [DeviceDetection detectDevice];
    switch (device) {
        case MODEL_IPHONE_SIMULATOR:
        case MODEL_IPOD_TOUCH_GEN3:
        case MODEL_IPOD_TOUCH_GEN4:
        case MODEL_IPHONE_3GS:
        case MODEL_IPHONE_4:
        case MODEL_IPHONE_4S:            
            profile = kPerformanceHigh;
            break;           
        case MODEL_IPAD_SIMULATOR:
        case MODEL_IPAD:
        case MODEL_IPAD2:
        case MODEL_IPAD3:
            profile = kPerformanceHigh;
            break;
        case MODEL_IPOD_TOUCH_GEN2:
            profile = kPerformanceMedium;
            break;
        case MODEL_IPHONE:
        case MODEL_IPHONE_3G:
        case MODEL_IPOD_TOUCH_GEN1:
            profile = kPerformanceLow;
            break;
        default:
            profile = kPerformanceHigh;
            break;
    }
}


@end
