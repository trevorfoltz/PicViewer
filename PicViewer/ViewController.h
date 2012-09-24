//
//  ViewController.h
//  PicViewer
//
//  Created by Trevlord on 8/14/12.
//  Copyright (c) 2012 Trevlord. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>


@interface ViewController : UIViewController
{
    UIImageView *currentImg, *nextImg, *previousImg;
    NSTimer *slideshowTimer, *animateTimer;
    NSMutableArray *imgList, *imgNamesList, *usedImgList, *imgURLs, *imgCache;
    
    NSInteger imgCounter, imgTotal;
    UILabel *countLbl, *pathLbl;
    ALAssetsLibrary *alLibrary;
    CALayer *imgLayer1, *imgLayer2;
    BOOL didPause, layerToggle, didGrow, isAnimating;
    
}

@property (nonatomic, retain) CALayer *imgLayer1, *imgLayer2;
@property (nonatomic, retain) ALAssetsLibrary *alLibrary;
@property (nonatomic, retain) IBOutlet UILabel *countLbl, *pathLbl;
@property (nonatomic, retain) UIImageView *currentImg, *nextImg, *previousImg;
@property (nonatomic, retain) NSTimer *slideshowTimer, *animateTimer;
@property (nonatomic, retain) NSMutableArray *imgList, *imgNamesList, *usedImgList, *imgURLs, *imgCache;
@property (nonatomic, assign) NSInteger imgCounter, imgTotal;
@property (nonatomic, assign) BOOL didPause, layerToggle, didGrow, isAnimating;


- (void)loadImageCacheFromLibrary;

- (void)getAllImageNames;

- (NSString *)getNextImgName;

- (void)showNextImg:(id) sender;


- (void)animateImgBig:(id) sender;

- (void)animateImgDown:(id) sender;

- (void)animateImgUp:(id) sender;

- (void)animateImgSmall:(id) sender;

- (void)getImageURLs;
@end
