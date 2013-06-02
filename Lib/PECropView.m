//
//  PECropView.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "PECropView.h"
#import "PECropRectView.h"

static const CGFloat MarginTop = 37.0f;
static const CGFloat MarginBottom = MarginTop;
static const CGFloat MarginLeft = 20.0f;
static const CGFloat MarginRight = MarginLeft;

@interface PECropView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *zoomingView;
@property (nonatomic) UIImageView *imageView;

@property (nonatomic) PECropRectView *cropRectView;

@property (nonatomic) CALayer *overlayLayer;
@property (nonatomic) CAShapeLayer *cropLayer;

@property (nonatomic) CGRect insetRect;
@property (nonatomic) CGRect editingRect;
@property (nonatomic) CGRect cropRect;

@property (nonatomic, getter = isResizing) BOOL resizing;
@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

@end

@implementation PECropView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.maximumZoomScale = 10.0f;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        self.scrollView.bouncesZoom = NO;
        self.scrollView.clipsToBounds = NO;
        [self addSubview:self.scrollView];
        
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
        rotationGestureRecognizer.delegate = self;
        [self.scrollView addGestureRecognizer:rotationGestureRecognizer];
        
        self.cropRectView = [[PECropRectView alloc] init];
        self.cropRectView.delegate = self;
        [self addSubview:self.cropRectView];
        
        self.overlayLayer = [CALayer layer];
        self.overlayLayer.bounds = self.layer.bounds;
        self.overlayLayer.position = self.layer.position;
        self.overlayLayer.backgroundColor = [[UIColor blackColor] CGColor];
        self.overlayLayer.opacity = 0.4f;
        [self.layer addSublayer:self.overlayLayer];
        
        self.cropLayer = [CAShapeLayer layer];
        self.cropLayer.bounds = self.overlayLayer.bounds;
        self.cropLayer.position = self.overlayLayer.position;
        self.cropLayer.fillRule = kCAFillRuleEvenOdd;
        self.overlayLayer.mask = self.cropLayer;
    }
    
    return self;
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint locationInImageView = [self convertPoint:point toView:self.imageView];
    CGPoint zoomedPoint = CGPointMake(locationInImageView.x * self.scrollView.zoomScale, locationInImageView.y * self.scrollView.zoomScale);
    if (!CGRectContainsPoint(CGRectInset(self.scrollView.frame, -22.0f, -22.0f), point) && CGRectContainsPoint(self.imageView.frame, zoomedPoint)) {
        return self.scrollView;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.image) {
        return;
    }
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        self.editingRect = CGRectInset(self.bounds, MarginLeft, MarginTop);
    } else {
        self.editingRect = CGRectInset(self.bounds, MarginLeft, MarginLeft);
    }
    
    if (!self.imageView) {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            self.insetRect = CGRectInset(self.bounds, MarginLeft, MarginTop);
        } else {
            self.insetRect = CGRectInset(self.bounds, MarginLeft, MarginLeft);
        }
        
        [self setupImageView];
    }
    
    if (!self.isResizing) {
        self.overlayLayer.bounds = self.bounds;
        self.overlayLayer.position = self.center;
        self.cropLayer.bounds = self.overlayLayer.bounds;
        self.cropLayer.position = self.overlayLayer.position;
        
        [self layoutCropRectViewWithCropRect:self.scrollView.frame];
        [self layoutCropLayerWithCropRect:self.scrollView.frame];
        
        if (self.interfaceOrientation != interfaceOrientation) {
            [self zoomToCropRect:self.scrollView.frame];
        }
    }
    
    self.interfaceOrientation = interfaceOrientation;
}

- (void)layoutCropRectViewWithCropRect:(CGRect)cropRect
{
    self.cropRectView.frame = cropRect;
}

- (void)layoutCropLayerWithCropRect:(CGRect)cropRect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cropLayer.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRect:cropRect]];
    self.cropLayer.path = path.CGPath;
}

- (void)setupImageView
{
    self.cropRect = AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect);
    
    self.scrollView.frame = self.cropRect;
    self.scrollView.contentSize = self.cropRect.size;
    
    self.zoomingView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.zoomingView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.zoomingView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.zoomingView.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
    [self.zoomingView addSubview:self.imageView];
}

#pragma mark -

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.zoomingView removeFromSuperview];
    self.zoomingView = nil;
    
    [self setNeedsLayout];
}


- (UIImage *)croppedImage
{
    CGRect cropRect = [self convertRect:self.scrollView.frame toView:self.zoomingView];
    CGSize size = self.image.size;
    
    CGFloat ratio = 1.0f;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(orientation)) {
        ratio = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect)) / size.width;
    } else {
        ratio = CGRectGetHeight(AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect)) / size.height;
    }
    
    CGRect zoomedCropRect = CGRectMake(cropRect.origin.x / ratio,
                                       cropRect.origin.y / ratio,
                                       cropRect.size.width / ratio,
                                       cropRect.size.height / ratio);
    
    UIImage *rotatedImage = [self rotatedImageWithImage:self.image transform:self.imageView.transform];
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, zoomedCropRect);
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:1.0f orientation:rotatedImage.imageOrientation];
    CGImageRelease(croppedImage);
    
    return image;
}

- (UIImage *)rotatedImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform
{
    CGSize size = image.size;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rotatedImage;
}

- (CGRect)cappedCropRectInImageRectWithCropRectView:(PECropRectView *)cropRectView
{
    CGRect cropRect = cropRectView.frame;
    
    CGRect rect = [self convertRect:cropRect toView:self.scrollView];
    if (CGRectGetMinX(rect) < CGRectGetMinX(self.zoomingView.frame)) {
        cropRect.origin.x = CGRectGetMinX([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        cropRect.size.width = CGRectGetMaxX(rect);
    }
    if (CGRectGetMinY(rect) < CGRectGetMinY(self.zoomingView.frame)) {
        cropRect.origin.y = CGRectGetMinY([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        cropRect.size.height = CGRectGetMaxY(rect);
    }
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.zoomingView.frame)) {
        cropRect.size.width = CGRectGetMaxX([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinX(cropRect);
    }
    if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.zoomingView.frame)) {
        cropRect.size.height = CGRectGetMaxY([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinY(cropRect);
    }
    
    return cropRect;
}

- (void)automaticZoomIfEdgeTouched:(CGRect)cropRect
{
    if (CGRectGetMinX(cropRect) < CGRectGetMinX(self.editingRect) - 5.0f ||
        CGRectGetMaxX(cropRect) > CGRectGetMaxX(self.editingRect) + 5.0f ||
        CGRectGetMinY(cropRect) < CGRectGetMinY(self.editingRect) - 5.0f ||
        CGRectGetMaxY(cropRect) > CGRectGetMaxY(self.editingRect) + 5.0f) {
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self zoomToCropRect:self.cropRectView.frame];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

#pragma mark -

- (void)cropRectViewDidBeginEditing:(PECropRectView *)cropRectView
{
    self.resizing = YES;
}

- (void)cropRectViewEditingChanged:(PECropRectView *)cropRectView
{
    CGRect cropRect = [self cappedCropRectInImageRectWithCropRectView:cropRectView];
    
    [self layoutCropRectViewWithCropRect:cropRect];
    [self layoutCropLayerWithCropRect:cropRect];
    
    [self automaticZoomIfEdgeTouched:cropRect];
}

- (void)cropRectViewDidEndEditing:(PECropRectView *)cropRectView
{
    self.resizing = NO;
    [self zoomToCropRect:self.cropRectView.frame];
}

- (void)zoomToCropRect:(CGRect)cropRect
{
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    
    CGFloat scale = MIN(CGRectGetWidth(self.editingRect) / width, CGRectGetHeight(self.editingRect) / height);
    
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    self.cropRect = CGRectMake((CGRectGetWidth(self.bounds) - scaledWidth) / 2,
                               (CGRectGetHeight(self.bounds) - scaledHeight) / 2,
                               scaledWidth,
                               scaledHeight);
    
    CGRect zoomRect = [self convertRect:cropRect toView:self.zoomingView];
    zoomRect.size.width = CGRectGetWidth(self.cropRect) / (self.scrollView.zoomScale * scale);
    zoomRect.size.height = CGRectGetHeight(self.cropRect) / (self.scrollView.zoomScale * scale);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cropLayer.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRect:self.cropRect]];
    self.cropLayer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    [self.cropLayer addAnimation:animation forKey:nil];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.bounds = self.cropRect;
                         [self.scrollView zoomToRect:zoomRect animated:NO];
                         
                         [self layoutCropRectViewWithCropRect:self.cropRect];
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark -

- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer
{
    CGFloat rotation = gestureRecognizer.rotation;
    
    CGAffineTransform transform = CGAffineTransformRotate(self.imageView.transform, rotation);
    self.imageView.transform = transform;
    gestureRecognizer.rotation = 0.0f;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.cropRectView.showsGridMinor = YES;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
               gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.cropRectView.showsGridMinor = NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

@end
