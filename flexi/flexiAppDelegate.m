//
//  flexiAppDelegate.m
//  flexi
//
//  Created by Kamil Smuga on 16/01/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "flexiAppDelegate.h"
#import "LoginViewController.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import <CouchbaseLite/CBLManager.h>
#import <CouchbaseLite/CBLDocument.h>
#import <FacebookSDK/FacebookSDK.h>

#import "Profile.h"

// name of local database stored in iOS
#define localDBName @"flexi-sync"
// remote DB URL
#define remoteDBUrl @"http://sync.couchbasecloud.com/flexidb/"
#define kFBAppId @"241876219329233"


@implementation flexiAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

// store remoteDBUrl in UserDefaults
#ifdef remoteDBUrl
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appdefaults = [NSDictionary dictionaryWithObject:remoteDBUrl
                                                            forKey:@"syncpoint"];
    [defaults registerDefaults:appdefaults];
    [defaults synchronize];
#endif
    
    // UINavigation controller try
    /*
    UIViewController *myViewController = [[LoginViewController alloc] init];
    self.navigationController = [[UINavigationController alloc]
                            initWithRootViewController:myViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    */
    
    
    
    
    
    // Initialize Couchbase Lite and find/create my database:
    /*
    NSError* error;
    self.database = [[CBLManager sharedInstance] databaseNamed:localDBName error: &error];
    if (!self.database)
        [self showAlert: @"Couldn't open database" error: error fatal: YES];
    
    NSLog(@"DB url: %@", [defaults stringForKey:@"syncpoint"]);
    [self setupCBLSync];
*/
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    NSLog(@"Handled? : %hhd", wasHandled);
    NSLog(@"Url info : %@", url);
    NSLog(@"Source app info : %@", sourceApplication);
    NSLog(@"annotation info : %@", annotation);
    
    return wasHandled;
}


- (BOOL) sayHello
{
    NSError *error;
    CBLManager *manager = [CBLManager sharedInstance];
    
    if (!manager) {
        NSLog (@"Cannot create shared instance of CBLManager");
        return NO;
    }
    
    NSString *dbName = @"flexidb";
    if (![CBLManager isValidDatabaseName:dbName]) {
        NSLog(@"not a valid name");
        return NO;
    }
    
    if (!self.database) {
        return NO;
    }
    
    NSDictionary *myDictionary =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"Hello Couchbase Lite!", @"message",
     [[NSDate date] description], @"timestamp",
     nil];
    
    NSLog (@"This is the data for the document: %@", myDictionary);
    
    CBLDocument *doc = [self.database createDocument];
    CBLRevision *newRevision = [doc putProperties:myDictionary error:&error];
    
    if (!newRevision) {
        NSLog (@"Cannot write document to database. Error message: %@", error.localizedDescription);
    }
    
    
    CBLQuery *query = [self.database createAllDocumentsQuery];
    query.descending = YES;
    
    CBLQueryEnumerator *rowEnum = [query run:&error];
    
    for (CBLQueryRow *row in rowEnum) {
        NSLog(@"doc id: %@", row.key);
        NSLog(@"doc: %@", row.document.properties);
    }
    
    
    /*
    // save the ID of the new document
    NSString *docID = doc.documentID;
    
    // retrieve the document from the database
    CBLDocument *retrievedDoc = [self.database documentWithID: docID];
    
    // display the retrieved document
    NSLog(@"The retrieved document contains: %@", retrievedDoc.properties);
    */
    

    
    
    return YES;
    
}

// Display an error alert, without blocking.
// If 'fatal' is true, the app will quit when it's dismissed.
- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal {
    if (error) {
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedDescription];
    }
    NSLog(@"ALERT: %@ (error=%@)", message, error);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: (fatal ? @"Fatal Error" : @"Error")
                                                    message: message
                                                   delegate: (fatal ? self : nil)
                                          cancelButtonTitle: (fatal ? @"Quit" : @"Sorry")
                                          otherButtonTitles: nil];
    [alert show];
}


- (void) setupCBLSync {
    _cblSync = [[CBLSyncManager alloc] initSyncForDatabase:_database withURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"syncpoint"]]];
    
    // Tell the Sync Manager to use Facebook for login.
    _cblSync.authenticator = [[CBLFacebookAuthenticator alloc] initWithAppID:kFBAppId];
    
    if (_cblSync.userID) {
        //        we are logged in, go ahead and sync
        [_cblSync start];
        NSLog(@"logged in! cool");
    } else {
        // Application callback to create the user profile.
        // this will be triggered after we call [_cblSync start]
        NSLog(@"not logged in");
        [_cblSync beforeFirstSync:^(NSString *userID, NSDictionary *userData,  NSError **outError) {
            // This is a first run, setup the profile but don't save it yet.
            Profile *myProfile = [[Profile alloc] initCurrentUserProfileInDatabase:self.database withName:userData[@"name"] andUserID:userID];
            
            
            // Sync doesn't start until after this block completes, so
            // all this data will be tagged.
            if (!outError) {
                [myProfile save:outError];
            }
            else {
                NSLog(@"DUPA");
            }
        }];
    }
}



@end
