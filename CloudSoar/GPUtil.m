//
//  GPUtil.m
//  CloudSoar
//
//  Created by Min Kwon on 3/21/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "GPUtil.h"

@implementation GPUtil

+ (double) randomFrom:(double)n1 to:(double)n2 {
    double diff = n2 - n1;
    double r = n1 + (((double)arc4random()) / 0xFFFFFFFFu)*diff;
    return r;
}

@end
