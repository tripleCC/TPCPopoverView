//
//  TPCPopView.h
//  TPCPopView
//
//  Created by tripleCC on 15/10/22.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TPCPopViewFadeDirection) {
    TPCPopViewFadeDirectionLeftTop = 0,
    TPCPopViewFadeDirectionRightTop = 1,
    TPCPopViewFadeDirectionCenter = 2,
};

@class TPCPopView;
@protocol TPCPopViewDataSource <NSObject>
- (UITableViewCell *)popView:(TPCPopView *)popView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)popView:(TPCPopView *)popView numberOfRowsInSection:(NSInteger)section;
@optional
- (CGFloat)popView:(TPCPopView *)popView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol TPCPopViewDelegate <NSObject>
@optional
- (void)popView:(TPCPopView *)popView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface TPCPopView : UIView
@property (strong, nonatomic) UIColor *backgroundColor;
@property (weak, nonatomic) id<TPCPopViewDataSource> dataSource;
@property (weak, nonatomic) id<TPCPopViewDelegate> delegate;
+ (void)showMessages:(NSArray *)messages
  withContainerFrame:(CGRect)containerFrame
       fadeDirection:(TPCPopViewFadeDirection)fadeDirection
    clickActionBlock:(void (^)(NSInteger))clickActionBlock;
+ (void)showMessages:(NSArray *)messages
   withContainerSize:(CGSize)containerSize
            fromView:(UIView *)fromView
       fadeDirection:(TPCPopViewFadeDirection)fadeDirection
    clickActionBlock:(void (^)(NSInteger))clickActionBlock;
+ (void)showWithContainerSize:(CGSize)containerSize
            fromView:(UIView *)fromView
       fadeDirection:(TPCPopViewFadeDirection)fadeDirection
          dataSource:(id<TPCPopViewDataSource>)dataSource
            delegate:(id<TPCPopViewDelegate>)delegate;
@end
