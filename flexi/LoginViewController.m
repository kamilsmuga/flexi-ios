//
//  LoginViewController.m
//  flexi
//
//  Created by Kamil Smuga on 16/01/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "flexiAppDelegate.h"
#import "Profile.h"
#import <FacebookSDK/FacebookSDK.h>
#import <CouchbaseLite/CouchbaseLite.h>


@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) FBLoginView *fbView;
@property (strong, nonatomic) NSMutableData* imageData;
@property (nonatomic, weak) CBLDatabase *db;
@property (strong, nonatomic) NSString *email;
@end

@implementation LoginViewController

-(CBLDatabase *)db
{
    if (!_db) {
        _db = ((flexiAppDelegate*)[UIApplication sharedApplication].delegate).database;
    }
    return _db;
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    self.fbView = loginView;
    [self performSegueWithIdentifier:@"toMainView" sender:self];
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.email = [user objectForKey:@"email"];
    self.imageData = [[NSMutableData alloc] init];
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", user.id]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:2.0f];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
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
        NSLog(@"Finished loading image. Wooohooo!");
    }
    
}



// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    
    self.profilePictureView.profileID = nil;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"toMainView"]) {
        MainViewController *secondController = [segue destinationViewController];
        self.fbView.delegate = secondController;
    }
}

@end
