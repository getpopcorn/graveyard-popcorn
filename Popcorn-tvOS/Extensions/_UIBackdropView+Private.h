//
//  _UIBackdropView+Private.h
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 3/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3;
- (id)initWithPrivateStyle:(int)arg1;
- (id)initWithSettings:(id)arg1;
- (id)initWithStyle:(int)arg1;

- (void)setBlurFilterWithRadius:(float)arg1 blurQuality:(id)arg2 blurHardEdges:(int)arg3;
- (void)setBlurFilterWithRadius:(float)arg1 blurQuality:(id)arg2;
- (void)setBlurHardEdges:(int)arg1;
- (void)setBlurQuality:(id)arg1;
- (void)setBlurRadius:(float)arg1;
- (void)setBlurRadiusSetOnce:(BOOL)arg1;
- (void)setBlursBackground:(BOOL)arg1;
- (void)setBlursWithHardEdges:(BOOL)arg1;

- (void)transitionToColor:(id)arg1;

@property(nonatomic) BOOL requiresTintViews;
@property (nonatomic) double colorTintAlpha;
@property (nonatomic) double colorTintMaskAlpha;
@end

@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForStyle:(int)arg1;
@end
