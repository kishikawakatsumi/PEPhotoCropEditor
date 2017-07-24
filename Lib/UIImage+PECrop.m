//
//  UIImage+PECrop.m
//  PhotoCropEditor
//
//  Created by Ernesto Rivera on 2013/07/29.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "UIImage+PECrop.h"

@implementation UIImage (PECrop)

- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)transform
                         croppedToRect:(CGRect)originalCropRect
{
    // if not rotated - just cropping will do
    if (CGAffineTransformIsIdentity(transform)) {
        CGRect adjustedCropRect = [self pe_orientationAdjustedCropRect:originalCropRect];
        CGImageRef image = CGImageCreateWithImageInRect(self.CGImage, adjustedCropRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:image scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(image);
        return croppedImage;
    }

    return [self pe_coreGraphicsRotatedImageWithTransform:transform cropRect:originalCropRect];
}

- (UIImage *)pe_coreGraphicsRotatedImageWithTransform:(CGAffineTransform)transform
                                             cropRect:(CGRect)originalCropRect
{
    UIGraphicsBeginImageContextWithOptions(originalCropRect.size,
                                           YES,                     // Opaque
                                           self.scale);             // Use image scale
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(context, -originalCropRect.origin.x, -originalCropRect.origin.y);
    CGContextTranslateCTM(context, self.size.width / 2, self.size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, self.size.width / -2, self.size.height / -2);

    [self drawAtPoint:CGPointZero];

    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rotatedImage;
}

- (CGRect)pe_orientationAdjustedCropRect:(CGRect)originalCropRect {

    CGAffineTransform rectTransform;
    switch (self.imageOrientation)
    {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            rectTransform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -self.size.width, -self.size.height);
            break;
    };

    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    CGRect transformed = CGRectApplyAffineTransform(originalCropRect, rectTransform);
    transformed.origin.x = round(transformed.origin.x);
    transformed.origin.y = round(transformed.origin.y);
    transformed.size.width = round(transformed.size.width);
    transformed.size.height = round(transformed.size.height);
    return  transformed;
}

@end
