//
//  CoverflowViewController.m
//  Created by Devin Ross on 1/3/10.
//
/*
 
 tapku || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
*/
#import "CoverflowVC.h"

#pragma mark - CoverflowViewController
@implementation CoverflowVC

- (NSUInteger) supportedInterfaceOrientations{
	return  UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
	return YES;
}

-(NSMutableArray*) covers
{
    if (!_covers) {
        _covers = [[NSMutableArray alloc] init];
    }
    return _covers;
}


#pragma mark View Lifecycle
- (void) loadView{
	
	CGRect rect = [UIScreen mainScreen].bounds;
	rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(90 * M_PI / 180.));
	rect.origin = CGPointZero;
	
	self.view = [[UIView alloc] initWithFrame:rect];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	
	self.coverflow = [[TKCoverflowView alloc] initWithFrame:self.view.bounds];
	self.coverflow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.coverflow.coverflowDelegate = self;
	self.coverflow.coverflowDataSource = self;
	self.coverflow.tag = 0;
	if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
		self.coverflow.coverSize = CGSizeMake(300, 300);
	}
	
	[self.view addSubview:self.coverflow];

	CGSize s = self.view.bounds.size;
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(info) forControlEvents:UIControlEventTouchUpInside];
	infoButton.frame = CGRectMake(s.width-50, 5, 50, 30);
	[self.view addSubview:infoButton];
	
	
	UIView *center = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2.0, 0,1, 1000)];
	center.backgroundColor = [UIColor redColor];
	center.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	//[self.view addSubview:center];
	
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Tap Me" style:UIBarButtonItemStyleBordered target:self action:@selector(info)];
	self.navigationItem.rightBarButtonItem = item;
	
}
- (void) viewDidLoad {
    [super viewDidLoad];

    if (self.notesData) {
        for (UIView *cell in self.notesData) {
            UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.opaque, 0.0);
            [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
            
            UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            [self.covers addObject:img];
        }
    }

	[self.coverflow reloadData];
	[self.coverflow setCurrentCoverAtIndex:9 animated:NO];

}
- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
	}
	
}
- (void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	
}
- (void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
	}
}

- (void) info{
	if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && self.coverflow.tag != 0){
		[self dismissViewControllerAnimated:YES completion:nil];
		return;
	}
	
	
	if(self.coverflow.tag == 0){
		
		CGFloat a = 30 * M_PI / 180.0;
		CGFloat z = -100;
		CGFloat x = self.coverflow.coverSize.width / 3;
		
		self.coverflow.leftTransform = CATransform3DConcat(CATransform3DMakeRotation(50 * M_PI / 180.0, 0, 1, 0), CATransform3DMakeTranslation(-x, 0, z));
		self.coverflow.rightTransform = CATransform3DConcat(CATransform3DMakeRotation(a, 0, 1, 0), CATransform3DMakeTranslation(x , 0, z));

		
		self.coverflow.leftIncrementalDistanceFromCenter = 100;
		self.coverflow.rightIncrementalDistanceFromCenter = 100;
		self.coverflow.spacing =  self.coverflow.coverSize.width - 100;
		self.coverflow.tag = 1;
		[self.coverflow reloadData];
		
		return;
	}else{
		
		self.coverflow.tag = 0;

		
		CGFloat x = self.coverflow.coverSize.width / 2;
		CATransform3D lt = CATransform3DMakeRotation(80 * M_PI / 180.0, 0, 1, 0);
		self.coverflow.leftTransform = CATransform3DConcat(lt, CATransform3DMakeTranslation(-x, 0, -200));
		
		CATransform3D rt = CATransform3DMakeRotation(-80 * M_PI / 180.0, 0, 1, 0);
		self.coverflow.rightTransform = CATransform3DConcat(rt, CATransform3DMakeTranslation(x, 0, -200));

	}
	
	[self.coverflow reloadData];


}

- (NSInteger) numberOfCoversInCoverflowView:(TKCoverflowView *)coverflowView{
	return 20;
}
- (TKCoverflowCoverView *) coverflowView:(TKCoverflowView *)coverflowView coverForIndex:(NSInteger)index{
	
	TKCoverflowCoverView *cover = [coverflowView dequeueReusableCoverView];
	
	if(cover == nil){
		CGRect rect = CGRectMakeWithSize(0, 0, self.coverflow.coverSize);
		
		cover = [[TKCoverflowCoverView alloc] initWithFrame:rect reflection:YES]; // 224
	}
	cover.image = self.covers[index%[self.covers count]];
	return cover;
	
}

- (void) coverflowView:(TKCoverflowView*)coverflowView coverAtIndexWasBroughtToFront:(NSInteger)index{
	NSLog(@"Cover at index %@ was brought to front",@(index));
}


@end