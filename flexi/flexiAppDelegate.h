//
//  flexiAppDelegate.h
//  flexi
//
//  Created by Kamil Smuga on 16/01/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBLSyncManager.h"

@interface flexiAppDelegate : UIResponder <UIApplicationDelegate>
{
    CBLReplication* _pull;
    CBLReplication* _push;
    NSError *_syncError;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CBLDatabase *database;
@property (strong, nonatomic) CBLSyncManager *cblSync;


@end
