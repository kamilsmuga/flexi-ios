//
//  LoginViewController.m
//  flexi
//
//  Created by Kamil Smuga on 16/01/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "LoginVC.h"
#import "MainCVC.h"
#import "flexiAppDelegate.h"
#import "Profile.h"
#import "DBTestDataFeed.h"
#import "Note.h"
#import "MenuVC.h"
#import "TimelineVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import <CouchbaseLite/CouchbaseLite.h>


@interface LoginVC ()
@property (strong, nonatomic) FBLoginView *fbView;
@property (strong, nonatomic) NSMutableData* imageData;
@property (weak, nonatomic) CBLDatabase *db;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) PKRevealController *pk;
@property (nonatomic) BOOL debug;
@property (strong, nonatomic) CBLDatabase *database;
@property (strong, nonatomic) CBLSyncManager *cblSync;
@property (nonatomic) BOOL visited;
@end

// name of local database stored in iOS
#define localDBName @"flexi"
// remote DB URL
#define remoteDBUrl @"http://192.168.1.11:4985/flexi/"
#define kFBAppId @"241876219329233"

@implementation LoginVC

-(CBLDatabase *)db
{
    if (!_db) {
        _db = ((flexiAppDelegate*)[UIApplication sharedApplication].delegate).database;
    }
    return _db;
}

-(void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:YES];
    self.visited = NO;
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    self.fbView = loginView;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    [self setupCBLSync];
    if (!self.visited) {
        self.visited = YES;
        [self loginAndSync: ^(){
            NSLog(@"called complete loginAndSync");
        }];
    }
    
    self.email = [user objectForKey:@"email"];
    self.fbView = loginView;
    
    self.debug = YES;
    
    NSString *email = [user objectForKey:@"email"];

    /*
    [DBTestDataFeed populateRandomNotesInDB:self.db forUserID:email];
    CBLQuery *q = [Note allNotesInDB:self.db forUserID:email];
    CBLQueryEnumerator *rowEnum = [q run:&error];
    for (CBLQueryRow* row in rowEnum) {
        NSLog(@"Doc id = %@ and subject = %@", row.key, row.value);
    }
    */
    
    // download user FB profile picture
    self.imageData = [[NSMutableData alloc] init];
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", user.id]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:2.0f];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConnection self];
    
    TimelineVC *rightViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"timelineVC"];
    MenuVC *leftViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"menuVC"];
    
    Profile *existingProfile = [Profile profileInDatabase:self.db  forUserID:email];
    leftViewController.profile = existingProfile;
    
    [self.revealController setRightViewController:rightViewController];
    [self.revealController setLeftViewController:leftViewController];
    
    MainCVC *main = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainCVC"];
    main.userID = self.email;
    
    self.pk = self.revealController;
    [self.revealController setFrontViewController:main];
    
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
   // headerImageView.image = [UIImage imageWithData:imageData];
    Profile *existingProfile = [Profile profileInDatabase:self.db  forUserID:self.email];
    if (existingProfile && ![existingProfile attachmentNamed:@"profilePicture"]) {
        NSError *error;
        [existingProfile setAttachmentNamed:@"profilePicture" withContentType:@"image/jpeg" content:self.imageData];
        [existingProfile save:&error];
        if (error) {
            NSLog(@"Error while trying to save attachment under profile %@", self.email);
        }
    }
    ((MenuVC*)self.pk.leftViewController).picture = self.imageData;
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    [self.revealController setLeftViewController:nil];
    [self.revealController setRightViewController:nil];
    self.name = nil;
}


// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - CouchDB synch

- (void)setupCBLSync {
    _cblSync = [[CBLSyncManager alloc] initSyncForDatabase:self.db withURL:[NSURL URLWithString:remoteDBUrl]];
    
    // Tell the Sync Manager to use Facebook for login.
    _cblSync.authenticator = [[CBLFacebookAuthenticator alloc] initWithAppID:kFBAppId];
    
    if (_cblSync.userID) {
        // we are logged in, go ahead and sync
        [_cblSync start];
    } else {
        // Application callback to create the user profile.
        // this will be triggered after we call [_cblSync start]
        
        [_cblSync beforeFirstSync:^(NSString *userID, NSDictionary *userData,  NSError **outError) {
            [self performSelectorOnMainThread:@selector(runBlock:) withObject:^{
                [self updateMyLists:userID userData:userData outError:outError];
            } waitUntilDone:YES];
        }];
        
    }
}

- (void)runBlock:(void (^)())block {
    block();
}

- (void)updateMyLists:(NSString *)userID userData:(NSDictionary *)userData outError:(NSError **)outError {
    // This is a first run, setup the profile but don't save it yet.
    
    Profile *myProfile = [[Profile alloc] initCurrentUserProfileInDatabase:self.db withName:userData[@"name"] andUserID:userID];
    
    // Sync doesn't start until after this block completes, so
    // all this data will be tagged.
    if (!outError) {
        [myProfile save:outError];
    }
}

- (void)loginAndSync:(void (^)())complete {
    if (_cblSync.userID) {
        complete();
    } else {
        [_cblSync beforeFirstSync:^(NSString *userID, NSDictionary *userData, NSError **outError) {
            complete();
        }];
        [_cblSync start];
    }
}


@end
