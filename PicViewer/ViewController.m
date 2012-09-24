//
//  ViewController.m
//  PicViewer
//
//  Created by Trevlord on 8/14/12.
//  Copyright (c) 2012 Trevlord. All rights reserved.
//

#import "ViewController.h"
#include <stdlib.h>
#import "TestFlight.h"

@interface ViewController ()
//IMG_1686_57x57.jpg
@end

@implementation ViewController

@synthesize currentImg, nextImg, previousImg, countLbl, pathLbl, alLibrary;
@synthesize slideshowTimer, imgList, imgCounter, animateTimer, didPause, imgNamesList, usedImgList, imgURLs, imgTotal;
@synthesize imgLayer1, imgLayer2, layerToggle, didGrow, imgCache, isAnimating;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.imgNamesList = [[NSMutableArray alloc] initWithCapacity:1];
    self.usedImgList = [[NSMutableArray alloc] initWithCapacity:1];
    self.imgCache = [[NSMutableArray alloc] initWithCapacity:1];
    [self getImageURLs];
    
    [self getAllImageNames];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
/*
    self.imgNamesList = [[NSMutableArray alloc] initWithCapacity:1];
    self.usedImgList = [[NSMutableArray alloc] initWithCapacity:1];

    [self getImageURLs];
    [self getAllImageNames];
    self.imgLayer1 = [CALayer layer];
    self.imgLayer1.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
    self.imgLayer1.backgroundColor = (__bridge CGColorRef)[UIColor clearColor];
    CGImageRef imgRef = [[UIImage imageNamed:@"IMG_1686.jpg"] CGImage];
    [self.imgLayer1 setContents:(__bridge id)imgRef];
    [self.view.layer addSublayer:self.imgLayer1];
    self.imgLayer2 = [CALayer layer];
    self.imgLayer2.frame = CGRectMake(160.0, 240.0, 1.0, 1.0);
    self.imgLayer2.backgroundColor = (__bridge CGColorRef)[UIColor clearColor];
    [self.view.layer addSublayer:self.imgLayer2];
 */
    self.imgLayer1 = [CALayer layer];
    self.imgLayer1.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
    self.imgLayer1.backgroundColor = (__bridge CGColorRef)[UIColor clearColor];
    CGImageRef imgRef = [[UIImage imageNamed:@"IMG_1686.jpg"] CGImage];
    [self.imgLayer1 setContents:(__bridge id)imgRef];
    [self.view.layer addSublayer:self.imgLayer1];
    self.imgLayer2 = [CALayer layer];
    self.imgLayer2.frame = CGRectMake(160.0, 240.0, 1.0, 1.0);
    self.imgLayer2.backgroundColor = (__bridge CGColorRef)[UIColor clearColor];
    [self.view.layer addSublayer:self.imgLayer2];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationLandscapeLeft && interfaceOrientation != UIInterfaceOrientationLandscapeRight);

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.didPause) {
        if (!self.isAnimating) {
            [self setDidPause:NO];
            self.slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(showNextImg:) userInfo:nil repeats:NO];
        }
    }
    else {
        [self setDidPause:YES];
    }
}

- (void)loadImageCacheFromLibrary
{
    if ([self.imgURLs count] == 0) {
        return;
    }
    __block CGImageRef retImg = nil;
    
    ALAssetsLibrary *theLibrary = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryAssetForURLResultBlock resultsBlock = ^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        UIImage *img1 = [UIImage imageWithCGImage:[representation fullScreenImage]];
        if (img1.size.width < img1.size.height && representation.orientation == ALAssetOrientationUp) {
            [self.imgCache addObject:img1];
 
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
        /*  A failure here typically indicates that the user has not allowed this app access
         to location data. In that case the error code is ALAssetsLibraryAccessUserDeniedError.
         In principle you could alert the user to that effect, i.e. they have to allow this app
         access to location services in Settings > General > Location Services and turn on access
         for this application.
         */
        NSLog(@"FAILED! due to error in domain %@ with error code %d", error.domain, error.code);
        // This sample will abort since a shipping product MUST do something besides logging a
        // message. A real app needs to inform the user appropriately.
        abort();
    };
    
    // Get the asset for the asset URL to create a screen image.
    for (int i = 0; i < 5; i++) {
        NSURL *mediaURL = [self.imgURLs objectAtIndex:[self getNextImgIndex]];
        [theLibrary assetForURL:mediaURL resultBlock:resultsBlock failureBlock:failureBlock];
    }
}


- (void)getNextImageFromLibrary
{
    __block CGImageRef retImg = nil;
    
    ALAssetsLibrary *theLibrary = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryAssetForURLResultBlock resultsBlock = ^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        UIImage *img1 = [UIImage imageWithCGImage:[representation fullScreenImage]];
        if (img1.size.width < img1.size.height && representation.orientation == ALAssetOrientationUp) {
            if (!self.layerToggle) {
                [self.imgLayer2 setContents:(__bridge id)[img1 CGImage]];
            }
            else {
                [self.imgLayer1 setContents:(__bridge id)[img1 CGImage]];
            }
        }
        else {
            [self getNextImageFromLibrary];
            
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
        /*  A failure here typically indicates that the user has not allowed this app access
         to location data. In that case the error code is ALAssetsLibraryAccessUserDeniedError.
         In principle you could alert the user to that effect, i.e. they have to allow this app
         access to location services in Settings > General > Location Services and turn on access
         for this application.
         */
        NSLog(@"FAILED! due to error in domain %@ with error code %d", error.domain, error.code);
        // This sample will abort since a shipping product MUST do something besides logging a
        // message. A real app needs to inform the user appropriately.
        abort();
    };
    
    // Get the asset for the asset URL to create a screen image.
    if (self.imgURLs != nil && [self.imgURLs count] > 0) {
        NSURL *mediaURL = [self.imgURLs objectAtIndex:[self getNextImgIndex]];
        [theLibrary assetForURL:mediaURL resultBlock:resultsBlock failureBlock:failureBlock];
    }
}

- (CGImageRef)getNextImageFromFile
{
//    CGImageRef retImg = nil;
    NSString *fName = [self getNextImgName];
    
    //        fName = [fName lastPathComponent];
    NSLog(@"Filename = %@", fName);
    UIImage *img2 = [UIImage imageWithContentsOfFile:fName];
    if (img2.size.height > img2.size.width) {
        return [img2 CGImage];
    }
    return [self getNextImageFromFile];
}

- (CGImageRef)getNextImageFromCache
{
    UIImage *img = [self.imgCache objectAtIndex:0];
    [self.imgCache removeObjectAtIndex:0];
    if ([self.imgCache count] < 3) {
        [self loadImageCacheFromLibrary];
    }
    return [img CGImage];
}

- (void)showNextImg:(id) sender
{
    self.isAnimating = YES;
    self.imgCounter++;
    if (self.imgCounter == 49) {
        self.imgTotal += 50;
        self.imgCounter = 0;
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"Images processed: %d", self.imgTotal]];
    }
    
    CGImageRef imgRef = nil;
    if (self.imgURLs != nil && [self.imgURLs count] > 0) {
        imgRef = [self getNextImageFromCache];
    }
    else {
        imgRef = [self getNextImageFromFile];
    }
    if (!self.layerToggle) {
        [self.imgLayer2 setContents:(__bridge id)imgRef];
    }
    else {
        [self.imgLayer1 setContents:(__bridge id)imgRef];
    }


    // Prepare the animation from the old size to the new size
    CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    growAnimation.duration = 0.3;
    growAnimation.delegate = self;
    
    
    CGSize growSize = CGSizeMake(320.0, 480.0);
    CGRect oldGrowBounds = CGRectMake(160.0, 240.0, 1.0, 1.0);
    
    CGRect newGrowBounds = oldGrowBounds;
    
    newGrowBounds.size = growSize;
    
    growAnimation.fromValue = [NSValue valueWithCGRect:oldGrowBounds];
    growAnimation.toValue = [NSValue valueWithCGRect:newGrowBounds];
    
    if (!self.layerToggle) {
        self.imgLayer2.bounds = newGrowBounds;
        
        [self.imgLayer1 setZPosition:0];
        [self.imgLayer2 setZPosition:1];
        [self.imgLayer2 addAnimation:growAnimation forKey:@"bounds"];
    }
    else {
        self.imgLayer1.bounds = newGrowBounds;
        [self.imgLayer2 setZPosition:0];
        [self.imgLayer1 setZPosition:1];
        
        [self.imgLayer1 addAnimation:growAnimation forKey:@"bounds"];
    }
    self.didGrow = YES;

    self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(animateImgBig:) userInfo:nil repeats:NO];
}

- (void)animateImgBig:(NSTimer *) timer
{
    
    CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    growAnimation.duration = 1.2;
    CGRect oldBounds = CGRectMake(0.0, 0.0, 320.0, 480.0);
        
    CGRect newBounds = oldBounds;
    newBounds.size = CGSizeMake(480.0, 720.0);
    
    growAnimation.fromValue = [NSValue valueWithCGRect:oldBounds];
    growAnimation.toValue = [NSValue valueWithCGRect:newBounds];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 1.2;
    CGPoint oldPos = self.view.center;
    CGPoint newPos = CGPointMake(oldPos.x, oldPos.y + 120.0);
    
    positionAnimation.fromValue = [NSValue valueWithCGPoint:oldPos];
    positionAnimation.toValue = [NSValue valueWithCGPoint:newPos];
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    [group setAnimations:[NSArray arrayWithObjects:growAnimation, positionAnimation, nil]];
    group.duration = 1.2;
    
    if (!self.layerToggle) {
        self.imgLayer2.bounds = newBounds;
        self.imgLayer2.position = newPos;
        [self.imgLayer2 addAnimation:group forKey:nil];
    }
    else {
        self.imgLayer1.bounds = newBounds;
        self.imgLayer1.position = newPos;
        [self.imgLayer1 addAnimation:group forKey:nil];
    }
    
    self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(animateImgUp:) userInfo:nil repeats:NO];
}


- (void)animateImgUp:(NSTimer *) timer
{
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"position"];
    anim1.duration = 1.8;

    CGPoint oldPos;
    if (!self.layerToggle) {
        oldPos = self.imgLayer2.position;
    }
    else {
        oldPos = self.imgLayer1.position;
    }
    CGPoint newPos = CGPointMake(oldPos.x, oldPos.y - 240.0);
    anim1.fromValue = [NSValue valueWithCGPoint:oldPos];
    anim1.toValue = [NSValue valueWithCGPoint:newPos];

    if (!self.layerToggle) {
        self.imgLayer2.position = newPos;
        [self.imgLayer2 addAnimation:anim1 forKey:@"position"];
    }
    else {
        self.imgLayer1.position = newPos;
        [self.imgLayer1 addAnimation:anim1 forKey:@"position"];
    }
    
    self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:2.2 target:self selector:@selector(animateImgSmall:) userInfo:nil repeats:NO];
}

- (void)animateImgSmall:(NSTimer *) timer
{
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"bounds"];
    anim1.duration = 1.2;
    
    CGRect oldBounds;
    if (!self.layerToggle) {
        oldBounds = self.imgLayer2.bounds;
    }
    else {
        oldBounds = self.imgLayer1.bounds;
    }
    
    CGRect newBounds = oldBounds;
    newBounds.size = CGSizeMake(320.0, 480.0);
    
    anim1.fromValue = [NSValue valueWithCGRect:oldBounds];
    anim1.toValue = [NSValue valueWithCGRect:newBounds];
    
    CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"position"];
    anim2.duration = 1.2;
    CGPoint oldPos;
    if (!self.layerToggle) {
        oldPos = self.imgLayer2.position;
    }
    else {
        oldPos = self.imgLayer1.position;
    }
    CGPoint newPos = oldPos;
    newPos.y += 120.0;
    anim2.fromValue = [NSValue valueWithCGPoint:oldPos];
    anim2.toValue = [NSValue valueWithCGPoint:newPos];
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.duration = 1.2;
    [group setAnimations:[NSArray arrayWithObjects:anim1, anim2, nil]];
    
    if (!self.layerToggle) {
        [self setLayerToggle:YES];
        self.imgLayer2.bounds = newBounds;
        self.imgLayer2.position = newPos;
        [self.imgLayer2 addAnimation:group forKey:nil];
    }
    else {
        [self setLayerToggle:NO];
        self.imgLayer1.bounds = newBounds;
        self.imgLayer1.position = newPos;
        [self.imgLayer1 addAnimation:group forKey:nil];
    }
    if (!self.didPause) {
        self.slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(showNextImg:) userInfo:nil repeats:NO];
    }
    self.isAnimating = NO;
}


- (void)getAllImageNames
{
    for (int i = 1006; i<2353; i++) {
        NSString *imgStr = [NSString stringWithFormat:@"IMG_%d.jpg", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:imgStr ofType:nil];
        if (path) {
            [self.imgNamesList addObject:path];
        }
    }
}


- (NSInteger)getNextImgIndex
{
    if ([self.usedImgList count] == [self.imgURLs count]) {
        [self.usedImgList removeAllObjects];
    }
    int value = (arc4random() % [self.imgURLs count]);
    NSNumber *intValue = [NSNumber numberWithInt:value];
    while ([self.usedImgList containsObject:intValue]) {
        value = (arc4random() % [self.imgURLs count]);
        intValue = [NSNumber numberWithInt:value];
    }
    [self.usedImgList addObject:intValue];
    return value;
}


- (NSString *)getNextImgName
{
    if ([self.usedImgList count] == [self.imgNamesList count]) {
        [self.usedImgList removeAllObjects];
    }
    int value = (arc4random() % [self.imgNamesList count]);
    NSString *imgName = [self.imgNamesList objectAtIndex:value];
    while ([self.usedImgList containsObject:imgName]) {
        value = (arc4random() % [self.imgNamesList count]);
        imgName = [self.imgNamesList objectAtIndex:value];
    }
    [self.usedImgList addObject:imgName];
    
    return imgName;
}


- (void)getImageURLs
{
    self.imgURLs = [[NSMutableArray alloc] initWithCapacity:1];
    
    alLibrary = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [alLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just videos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // For this example, we're only interested in the first item.
        [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                 // The end of the enumeration is signaled by asset == nil.
                                 if (alAsset) {
                                     ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                     if (representation != nil) {
                                         [self.imgURLs addObject:[representation url]];
                                     }
                                 }
                            }
             ];
    }
                         failureBlock: ^(NSError *error) {
                             // Typically you should handle an error more gracefully than this.
                             NSLog(@"No groups");
                         }];
    [self.currentImg performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:5.0];
    NSTimer *dickTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadImageCacheFromLibrary:) userInfo:nil repeats:NO];
    self.slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:9.0 target:self selector:@selector(showNextImg:) userInfo:nil repeats:NO];
}


@end
