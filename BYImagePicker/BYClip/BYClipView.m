//
//  BYClipView.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/24.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYClipView.h"
#import "UIView+BYLayout.h"
#import <math.h>

@interface BYClipView ()
@property (nonatomic, strong) UIView *leftTopControlView;
@property (nonatomic, strong) UIView *rightTopControlView;
@property (nonatomic, strong) UIView *leftBottomControlView;
@property (nonatomic, strong) UIView *rightBottomControlView;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGRect startRect;
@property (nonatomic, assign) CGPoint moveStartPoint;
@property (nonatomic, assign) CGPoint moveStartCenter;
@end

static const CGFloat controlWH = 40.0f;

@implementation BYClipView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [[UIColor whiteColor] set];
    UIRectFrame(CGRectMake(0, 0, roundf(self.by_width/3), self.by_height));
    UIRectFrame(CGRectMake(roundf(self.by_width/3 * 2), 0, roundf(self.by_width/3), self.by_height));
    UIRectFrame(CGRectMake(0, 0, self.by_width, roundf(self.by_height/3)));
    UIRectFrame(CGRectMake(0, roundf(self.by_height/3 * 2), self.by_width, roundf(self.by_height/3)));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.leftTopControlView.frame = (CGRect){ - controlWH / 2, - controlWH / 2, self.leftTopControlView.by_size};
    
    self.rightTopControlView.frame = (CGRect){self.by_width - controlWH / 2, -controlWH / 2, self.rightTopControlView.by_size};
    
    self.leftBottomControlView.frame = (CGRect){ - controlWH / 2, self.by_height - controlWH / 2, self.leftBottomControlView.by_size};
    
    self.rightBottomControlView.frame = (CGRect){self.by_width - controlWH / 2, self.by_height - controlWH / 2, self.rightBottomControlView.by_size};
}

- (void)setupView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, -2.5f, -2.5f)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.image = [UIImage imageNamed:@"cropIcon"];
    [self addSubview:imageView];
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveClipView:)];
    [self addGestureRecognizer:pan];
    
    self.leftTopControlView = [self resizeControlView:100];
    self.rightTopControlView = [self resizeControlView:200];
    self.leftBottomControlView = [self resizeControlView:300];
    self.rightBottomControlView = [self resizeControlView:400];
    [self setClippingRect:self.bounds];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if ([subview isEqual:self.leftTopControlView] && CGRectContainsPoint(subview.frame, point)) {
            return subview;
        }
        if ([subview isEqual:self.rightTopControlView] && CGRectContainsPoint(subview.frame, point)) {
            return subview;
        }
        if ([subview isEqual:self.leftBottomControlView] && CGRectContainsPoint(subview.frame, point)) {
            return subview;
        }
        if ([subview isEqual:self.rightBottomControlView] && CGRectContainsPoint(subview.frame, point)) {
            return subview;
        }
    }
    return self;
}

- (void)moveClipView:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.moveStartPoint = point;
        self.moveStartCenter = self.center;
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint center = CGPointMake(self.moveStartCenter.x + point.x - self.moveStartPoint.x, self.moveStartCenter.y + point.y - self.moveStartPoint.y);
        center.x = MIN(center.x, self.superview.by_width - self.by_width/2);
        center.x = MAX(center.x, self.by_width/2);
        
        center.y = MIN(center.y, self.superview.by_height - self.by_height/2);
        center.y = MAX(center.y, self.by_height/2);
        [self setCenter:center];
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
    }
}

- (void)panResizeControlView:(UIPanGestureRecognizer *)gesture
{
    UIView *panView = gesture.view;
    CGPoint translation = [gesture translationInView:self];
    CGRect rect = self.frame;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.startPoint = CGPointMake(translation.x, translation.y);
        self.startRect = self.frame;
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        CGPoint point = CGPointMake(self.startPoint.x + translation.x, self.startPoint.y + translation.y);
        if (panView == self.leftTopControlView) {
            rect = [self calcuTopLeftRectTranslationX:roundf(point.x) translationY:roundf(point.y)];
        } else if (panView == self.rightTopControlView) {
            rect = [self calcuTopRightRectTranslationX:roundf(point.x) translationY:roundf(point.y)];
        } else if (panView == self.leftBottomControlView) {
            rect = [self calcuLeftBottomRectTranslationX:roundf(point.x) translationY:roundf(point.y)];
        } else if (panView == self.rightBottomControlView) {
            rect = [self calcuRightBottomRectTranslationX:roundf(point.x) translationY:roundf(point.y)];
        }
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
    }
    self.frame = rect;
}

- (CGRect)calcuTopLeftRectTranslationX:(CGFloat)x translationY:(CGFloat)y
{
    float translationX = (float)x;
    float translationY = (float)y;
    translationY = roundf(x * self.heightRate * 1.0 / self.widthRate);
    
    CGRect rect = CGRectMake(CGRectGetMinX(self.startRect)+translationX, CGRectGetMinY(self.startRect) + translationY, CGRectGetWidth(self.startRect) - translationX, CGRectGetHeight(self.startRect) - translationY);
    
    if (CGRectGetWidth(rect) < 2*controlWH) {
        CGFloat width = 2*controlWH;
        CGFloat height = width * self.heightRate / self.widthRate;
        rect = CGRectMake(CGRectGetMinX(self.startRect) + CGRectGetWidth(self.startRect) - width, CGRectGetMinY(self.startRect) + CGRectGetHeight(self.startRect) - height, width, height);
    }
    
    if (CGRectGetHeight(rect) < 2*controlWH) {
        CGFloat height = 2*controlWH;
        CGFloat width = height * self.widthRate / self.heightRate;
        rect = CGRectMake(CGRectGetMinX(self.startRect) + CGRectGetWidth(self.startRect) - width, CGRectGetMinY(self.startRect) + CGRectGetHeight(self.startRect) - height, width, height);
    }

    if (CGRectGetMinX(rect) < 0) {
        CGFloat width = CGRectGetWidth(rect) + CGRectGetMinX(rect);
        CGFloat height = width * self.heightRate / self.widthRate;
        rect = CGRectMake(0, CGRectGetMinY(rect)+CGRectGetHeight(rect) - height, width, height);
    }
    
    if (CGRectGetMinY(rect) < 0) {
         CGFloat height = CGRectGetHeight(rect) + CGRectGetMinY(rect);
         CGFloat width = height * self.widthRate / self.heightRate;
         rect = CGRectMake(CGRectGetMinX(rect)+CGRectGetWidth(rect) - width, 0, width, height);
    }
    return rect;
}

- (CGRect)calcuLeftBottomRectTranslationX:(CGFloat)x translationY:(CGFloat)y
{
    float translationX = (float)x;
    float translationY = (float)y;
    translationY = roundf(x * self.heightRate * 1.0 / self.widthRate);
    
    CGRect rect = CGRectMake(CGRectGetMinX(self.startRect)+translationX, CGRectGetMinY(self.startRect), CGRectGetWidth(self.startRect) - translationX, CGRectGetHeight(self.startRect) - translationY);
    
    if (CGRectGetWidth(rect) < 2*controlWH) {
        CGFloat width = 2*controlWH;
        CGFloat height = width * self.heightRate / self.widthRate;
        rect = CGRectMake(CGRectGetMinX(self.startRect) + CGRectGetWidth(self.startRect) - width, CGRectGetMinY(self.startRect), width, height);
    }
    
    if (CGRectGetHeight(rect) < 2*controlWH) {
        CGFloat height = 2*controlWH;
        CGFloat width = height * self.widthRate / self.heightRate;
        rect = CGRectMake(CGRectGetMinX(self.startRect) + CGRectGetWidth(self.startRect) - width, CGRectGetMinY(self.startRect), width, CGRectGetHeight(rect));
    }

    if (CGRectGetMinX(rect) < 0) {
        CGFloat width = CGRectGetWidth(rect) + CGRectGetMinX(rect);
        CGFloat height = width * self.heightRate / self.widthRate;
        rect = CGRectMake(0, CGRectGetMinY(rect)+CGRectGetHeight(rect) - height, width, height);
    }
    
    if (CGRectGetMaxY(rect) > self.superview.by_height) {
        CGFloat height = self.superview.by_height - CGRectGetMinY(rect);
        CGFloat width = height * self.widthRate / self.heightRate;
        rect = CGRectMake(CGRectGetMinX(rect)+CGRectGetWidth(rect) - width, CGRectGetMinY(rect), width, height);
    }
    return rect;
}
- (CGRect)calcuRightBottomRectTranslationX:(CGFloat)x translationY:(CGFloat)y
{
    float translationX = (float)x;
    float translationY = (float)y;
    translationY = roundf(x * self.heightRate * 1.0 / self.widthRate);
    
    CGRect rect = CGRectMake(CGRectGetMinX(self.startRect), CGRectGetMinY(self.startRect), CGRectGetWidth(self.startRect) + translationX, CGRectGetHeight(self.startRect) + translationY);
    
    if (CGRectGetWidth(rect) < 2*controlWH) {
        CGFloat width = 2*controlWH;
        CGFloat height = width * self.heightRate / self.widthRate;
        rect = CGRectMake(CGRectGetMinX(self.startRect), CGRectGetMinY(self.startRect), width, height);
    }
    
    if (CGRectGetHeight(rect) < 2*controlWH) {
        CGFloat height = 2*controlWH;
        CGFloat width = height * self.widthRate / self.heightRate;
        rect = CGRectMake(CGRectGetMinX(self.startRect), CGRectGetMinY(self.startRect), width, CGRectGetHeight(rect));
    }
    
    if (CGRectGetMaxX(rect) > self.superview.by_width) {
        CGFloat width = self.superview.by_width - CGRectGetMinX(rect);
        CGFloat height = width * self.heightRate / self.widthRate;
        rect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), width, height);
    }
    
    if (CGRectGetMaxY(rect) > self.superview.by_height) {
        CGFloat height = self.superview.by_height - CGRectGetMinY(rect);
        CGFloat width = height * self.widthRate / self.heightRate;
        rect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), width, height);
    }
    
    return rect;
}


- (CGRect)calcuTopRightRectTranslationX:(CGFloat)x translationY:(CGFloat)y
{
    CGFloat translationX = x;
    CGFloat translationY = y;
    translationY = roundf(x * self.heightRate * 1.0 / self.widthRate);
    
    CGRect rect = CGRectMake(CGRectGetMinX(self.startRect), CGRectGetMinY(self.startRect) - translationY, CGRectGetWidth(self.startRect) + translationX, CGRectGetHeight(self.startRect) + translationY);
    
    if (CGRectGetWidth(rect) < 2*controlWH) {
        CGFloat width = 2*controlWH;
        CGFloat height = width * self.heightRate / self.widthRate;
        rect = CGRectMake(CGRectGetMinX(self.startRect), CGRectGetMinY(self.startRect) + CGRectGetHeight(self.startRect) - height, width, height);
    }
    
    if (CGRectGetHeight(rect) < 2*controlWH) {
        CGFloat height = 2*controlWH;
        CGFloat width = height * self.widthRate / self.heightRate;
        rect = CGRectMake(CGRectGetMinX(self.startRect), CGRectGetMinY(self.startRect) + CGRectGetHeight(self.startRect) - height, width, height);
    }
    
    if (CGRectGetMaxX(rect) > self.superview.by_width) {
        CGFloat width = self.superview.by_width - CGRectGetMinX(rect);
        CGFloat height = width * self.heightRate / self.widthRate;
        rect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect) - height, width, height);
    }
    
    if (CGRectGetMinY(rect) < 0) {
        CGFloat height = CGRectGetHeight(rect) + CGRectGetMinY(rect);
        CGFloat width = height * self.widthRate / self.heightRate;
        rect = CGRectMake(CGRectGetMinX(rect), 0, width, height);
    }
    return rect;
}

- (CGRect)resetRect:(CGRect)rect baseWidth:(BOOL)base
{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    if (base) {
        if (width < height) {
            height = width * MAX(self.heightRate, self.widthRate) / MIN(self.heightRate, self.widthRate);
        }else{
            height = width * MIN(self.heightRate, self.widthRate) / MAX(self.heightRate, self.widthRate);
        }
    }else{
        if (width < height) {
            width = height * MIN(self.heightRate, self.widthRate) / MAX(self.heightRate, self.widthRate);
        }else{
            width = height * MAX(self.heightRate, self.widthRate) / MIN(self.heightRate, self.widthRate);
        }
    }
    rect.size = CGSizeMake(width, height);
    return rect;
}

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    [self setNeedsDisplay];
}

- (void)setClippingRect:(CGRect)clippingRect animated:(BOOL)animated
{
    if(animated){
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.leftTopControlView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y) fromView:self];
                             self.leftBottomControlView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y+clippingRect.size.height) fromView:self];
                             self.rightTopControlView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y) fromView:self];
                             self.rightBottomControlView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y+clippingRect.size.height) fromView:self];
                         }
         ];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
        animation.duration = 0.2f;
        animation.fromValue = [NSValue valueWithCGRect:_clippingRect];
        animation.toValue = [NSValue valueWithCGRect:clippingRect];
        self.clippingRect = clippingRect;
        [self setNeedsDisplay];
    }else{
        self.clippingRect = clippingRect;
    }
}
#pragma mark - view
- (UIView *)resizeControlView:(NSInteger)tag
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, controlWH, controlWH)];
    view.backgroundColor = [UIColor clearColor];
    view.tag = tag;
    view.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panResizeControlView:)];
    [view addGestureRecognizer:panGesture];
    [self addSubview:view];
    return view;
}


@end
