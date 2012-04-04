//
//  ContactListener.m
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "ContactListener.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "Player.h"
#import "Energy.h"
#import "Rocket.h"
#import "SpriteObject.h"
#import "AudioEngine.h"

#define IS_PLAYER(x,y)              ([x gameObjectType] == kGameObjectPlayer || [y gameObjectType] == kGameObjectPlayer)
#define IS_ENERGY(x,y)              ([x gameObjectType] == kGameObjectEnergy || [y gameObjectType] == kGameObjectEnergy)
#define IS_ROCKET(x,y)              ([x gameObjectType] == kGameObjectRocket || [y gameObjectType] == kGameObjectRocket)

#define GAMEOBJECT_OF_TYPE(class, type, o1, o2)    (class*)([o1 gameObjectType] == type ? o1 : o2)

ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}


void ContactListener::BeginContact(b2Contact *contact) {
	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    if (IS_PLAYER(o1, o2)) {
        if (IS_ENERGY(o1, o2)) {
            Player *player = GAMEOBJECT_OF_TYPE(Player, kGameObjectPlayer, o1, o2);
            player.state = kPlayerStateGotEnergy;
            SpriteObject *energy =  GAMEOBJECT_OF_TYPE(Energy, kGameObjectEnergy, o1, o2);
            energy.gameObjectState = kGameObjectStateDestroy;
            
            [[AudioEngine sharedEngine] playEffect:SND_ENERGY sourceGroupId:CGROUP0_1VOICE];
        }
        else if (IS_ROCKET(o1, o2)) {
            Player *player = GAMEOBJECT_OF_TYPE(Player, kGameObjectPlayer, o1, o2);
            player.state = kPlayerStateGotRocket;
            if (player.rocketState != kPowerUpStateInEffect) {
                player.rocketState = kPowerUpStateReceived;
                SpriteObject *energy =  GAMEOBJECT_OF_TYPE(Rocket, kGameObjectRocket, o1, o2);
                energy.gameObjectState = kGameObjectStateDestroy;
            }
        }
    }
}

// EndContact is called when the contact end OR when the body is destroyed.
void ContactListener::EndContact(b2Contact *contact) {    
//	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
//	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();    
}

void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}