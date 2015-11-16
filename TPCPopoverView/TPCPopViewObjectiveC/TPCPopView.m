//
//  TPCPopView.m
//  TPCPopView
//
//  Created by tripleCC on 15/10/22.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCPopView.h"

#define TPCPopViewDefaultFrame CGRectMake(0, 0, 100, 60)
#define TPCPopViewDefaultThemeColor [UIColor whiteColor]
#define TPCPopViewDefaultCellHeight 30
#define TPCPopViewDefaultFont [UIFont systemFontOfSize:12.0]
#define TPCPopViewDefaultTextColor [UIColor grayColor]
#define TPCPopViewDefaultBottomLineColor [[UIColor lightGrayColor] colorWithAlphaComponent:0.3]

@interface TPCPopViewCell : UITableViewCell
@property (weak, nonatomic) UIView *bottomLine;
@property (assign, nonatomic, getter=isHideBottomLine) BOOL hideBottomLine;
@end

@implementation TPCPopViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = TPCPopViewDefaultThemeColor;
        self.textLabel.font = TPCPopViewDefaultFont;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = TPCPopViewDefaultBottomLineColor;
        [self.contentView addSubview:bottomLine];
        self.bottomLine = bottomLine;
    }

    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.bottomLine.frame = CGRectMake(0, CGRectGetMaxY(self.contentView.bounds) - 1, self.contentView.bounds.size.width - 10, 0.5);
}

- (void)setHideBottomLine:(BOOL)hideBottomLine {
    self.bottomLine.hidden = hideBottomLine;
}
@end

@interface TPCIndicatorView : UIView

@end

@implementation TPCIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [TPCPopViewDefaultThemeColor setFill];
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(CGRectGetWidth(rect)/2, 0)];
    [path addLineToPoint:CGPointMake(0, CGRectGetHeight(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(rect)/2, 0)];
    [path fill];
}
@end

@interface TPCPopView() <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIView *containerView;
@property (strong, nonatomic) NSArray *messages;
@property (assign, nonatomic) void(^clickActionBlock)(NSInteger row);
@end

static NSString *reuseIdentifier = @"popViewCellIdentifier";

@implementation TPCPopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        UIView *containerView = [[UIView alloc] initWithFrame:TPCPopViewDefaultFrame];
        containerView.backgroundColor = TPCPopViewDefaultThemeColor;
        containerView.layer.cornerRadius = 5.0;
        [self addSubview:containerView];
        self.containerView = containerView;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:containerView.frame];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor clearColor];
        [containerView addSubview:tableView];
        self.tableView = tableView;
        
        [tableView registerClass:[TPCPopViewCell class] forCellReuseIdentifier:reuseIdentifier];
    }
    
    return self;
}

- (void)setMessages:(NSArray *)messages {
    _messages = messages;
    self.tableView.frame = CGRectInset(self.containerView.bounds, 5, 5);
    [self.tableView reloadData];
}

- (void)dismiss {
    self.containerView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.containerView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    } completion:^(BOOL finished) {
        self.clickActionBlock = nil;
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(popView:numberOfRowsInSection:)]) {
        return [self.dataSource popView:self numberOfRowsInSection:section];
    } else {
        return self.messages.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(popView:heightForRowAtIndexPath:)]) {
        return [self.dataSource popView:self heightForRowAtIndexPath:indexPath];
    } else {
        return TPCPopViewDefaultCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(popView:cellForRowAtIndexPath:)]) {
        return [self.dataSource popView:self cellForRowAtIndexPath:indexPath];
    } else {
        TPCPopViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = self.messages[indexPath.row];
        cell.textLabel.textColor = TPCPopViewDefaultTextColor;
        if (indexPath.row == self.messages.count - 1) {
            cell.hideBottomLine = YES;
        }
        
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(popView:didSelectRowAtIndexPath:)]) {
        [self.delegate popView:self didSelectRowAtIndexPath:indexPath];
    } else {
        !self.clickActionBlock ? : self.clickActionBlock(indexPath.row);
    }
    [self dismiss];
}

- (void)setupIndicatorView {
    TPCIndicatorView *indicatorView = [[TPCIndicatorView alloc] initWithFrame:CGRectZero];
    if (self.containerView.layer.anchorPoint.x < 0.5) {
        indicatorView.frame = CGRectMake(5, -8, 16, 9);
    } else if(self.containerView.layer.anchorPoint.x > 0.5) {
        indicatorView.frame = CGRectMake(self.containerView.bounds.size.width - 21, -8, 16, 9);
    } else {
        indicatorView.frame = CGRectMake(self.containerView.bounds.size.width / 2 - 8, -8, 16, 9);
    }
    [self.containerView addSubview:indicatorView];
}

+ (void)showMessages:(NSArray *)messages
  withContainerFrame:(CGRect)containerFrame
         anchorPoint:(CGPoint)anchorPoint
    clickActionBlock:(void(^)(NSInteger row))clickActionBlock
          dataSource:(id<TPCPopViewDataSource>)dataSource
            delegate:(id<TPCPopViewDelegate>)delegate {
    CGRect trueFrame = containerFrame;
    trueFrame.origin.x -= containerFrame.size.width * (0.5 - anchorPoint.x);
    trueFrame.origin.y -= containerFrame.size.height * (0.5 - anchorPoint.y);
    TPCPopView *popView = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    popView.containerView.frame = trueFrame;
    popView.containerView.layer.anchorPoint = anchorPoint;
    [popView setupIndicatorView];
    popView.messages = messages;
    popView.clickActionBlock = clickActionBlock;
    popView.delegate = delegate;
    popView.dataSource = dataSource;
    [[UIApplication sharedApplication].keyWindow addSubview:popView];
    popView.alpha = 0;
    popView.containerView.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        popView.alpha = 1.0;
        popView.containerView.transform = CGAffineTransformIdentity;
    }];
}

+ (void)showMessages:(NSArray *)messages
  withContainerFrame:(CGRect)containerFrame
       fadeDirection:(TPCPopViewFadeDirection)fadeDirection
    clickActionBlock:(void (^)(NSInteger))clickActionBlock
          dataSource:(id<TPCPopViewDataSource>)dataSource
            delegate:(id<TPCPopViewDelegate>)delegate {
    CGRect trueFrame = containerFrame;
    CGPoint anchorPoint = CGPointZero;
    if (fadeDirection == TPCPopViewFadeDirectionLeftTop) {
        anchorPoint = CGPointMake((5 + 16 / 2) / containerFrame.size.width, -8 / containerFrame.size.height);
        trueFrame.origin.x -= 5 + 16 / 2;
    } else if (fadeDirection == TPCPopViewFadeDirectionRightTop) {
        anchorPoint = CGPointMake(1.0 - (5 + 16 / 2) / containerFrame.size.width, -8 / containerFrame.size.height);
        trueFrame.origin.x += 5 + 16 / 2 - containerFrame.size.width;
    } else if (fadeDirection == TPCPopViewFadeDirectionCenter) {
        anchorPoint = CGPointMake(0.5, -8 / containerFrame.size.height);
        trueFrame.origin.x -= containerFrame.size.width / 2;
    }
    trueFrame.origin.y += 8;
    
    [self showMessages:messages withContainerFrame:trueFrame anchorPoint:anchorPoint clickActionBlock:clickActionBlock dataSource:dataSource delegate:delegate];
}

+ (void)showMessages:(NSArray *)messages
   withContainerSize:(CGSize)containerSize
            fromView:(UIView *)fromView
       fadeDirection:(TPCPopViewFadeDirection)fadeDirection
    clickActionBlock:(void (^)(NSInteger))clickActionBlock
          dataSource:(id<TPCPopViewDataSource>)dataSource
            delegate:(id<TPCPopViewDelegate>)delegate {
    CGRect frame = CGRectMake(fromView.center.x, CGRectGetMaxY(fromView.frame) - 5, containerSize.width, containerSize.height);
    
    [self showMessages:messages withContainerFrame:frame fadeDirection:fadeDirection clickActionBlock:clickActionBlock dataSource:dataSource delegate:delegate];
}

+ (void)showMessages:(NSArray *)messages
  withContainerFrame:(CGRect)containerFrame
       fadeDirection:(TPCPopViewFadeDirection)fadeDirection
    clickActionBlock:(void (^)(NSInteger))clickActionBlock {
    [self showMessages:messages withContainerFrame:containerFrame fadeDirection:fadeDirection clickActionBlock:clickActionBlock dataSource:nil delegate:nil];
}

+ (void)showMessages:(NSArray *)messages
   withContainerSize:(CGSize)containerSize
            fromView:(UIView *)fromView
       fadeDirection:(TPCPopViewFadeDirection)fadeDirection
    clickActionBlock:(void (^)(NSInteger))clickActionBlock {
    [self showMessages:messages withContainerSize:containerSize fromView:fromView fadeDirection:fadeDirection clickActionBlock:clickActionBlock dataSource:nil delegate:nil];
}

+ (void)showWithContainerSize:(CGSize)containerSize
            fromView:(UIView *)fromView
       fadeDirection:(TPCPopViewFadeDirection)fadeDirection
          dataSource:(id<TPCPopViewDataSource>)dataSource
            delegate:(id<TPCPopViewDelegate>)delegate {
    [self showMessages:nil withContainerSize:containerSize fromView:fromView fadeDirection:fadeDirection clickActionBlock:nil dataSource:dataSource delegate:delegate];
}

+ (void)showWithContainerSize:(CGSize)containerSize fromView:(UIView *)fromView arrowDirection:(TPCPopViewFadeDirection)fadeDirection dataSource:(id<TPCPopViewDataSource>)dataSource delegate:(id<TPCPopViewDelegate>)delegate {
    
}
@end


