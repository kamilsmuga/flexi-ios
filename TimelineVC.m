//
//  SearchViewController.m
//  flexi
//
//  Created by Kamil Smuga on 4/13/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "TimelineVC.h"
#import "MainCVC.h"

@interface TimelineVC ()
@property (weak, nonatomic) IBOutlet UIView *allNotes;
@property (weak, nonatomic) IBOutlet UIView *recentNotes;
@property (weak, nonatomic) IBOutlet UIView *calendar;
@property (weak, nonatomic) IBOutlet UIView *dateRange;

@end

@implementation TimelineVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForAll)];
    self.allNotes.userInteractionEnabled = YES;
    [self.allNotes addGestureRecognizer:singleTap];
}

-(void) addTapDetectedForAll
{
    MainCVC *main = ((MainCVC*)self.revealController.frontViewController);
    [main initDataSource];
    [main reloadData];
    [[main revealController] showViewController:main];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end