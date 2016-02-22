/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * Created by james <https://github.com/mystcolor> on 9/28/11.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDecoder.h"

@implementation UIImage (ForceDecode)

+ (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images) {
        // Do not decode animated images
        return image;
    }
    
    CGImageRef imageRef = image.CGImage;
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                     alpha == kCGImageAlphaLast ||
                     alpha == kCGImageAlphaPremultipliedFirst ||
                     alpha == kCGImageAlphaPremultipliedLast);
    
    if (anyAlpha) { return image; }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGContextRef context = CGBitmapContextCreate(NULL, width,
                                                 height,
                                                 8,
                                                 0,
                                                 CGImageGetColorSpace(imageRef),
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(context);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(context);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

//+ (UIImage *)decodedImageWithImage:(UIImage *)image {
//    if (image.images) {
//        // Do not decode animated images
//        return image;
//    }
//
//    CGImageRef imageRef = image.CGImage;
//    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
//    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
//
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//
//    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
//    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
//            infoMask == kCGImageAlphaNoneSkipFirst ||
//            infoMask == kCGImageAlphaNoneSkipLast);
//
//    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
//    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
//    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
//        // Unset the old alpha info.
//        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
//
//        // Set noneSkipFirst.
//        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
//    }
//            // Some PNGs tell us they have alpha but only 3 components. Odd.
//    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
//        // Unset the old alpha info.
//        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
//        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
//    }
//
//    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
//    CGContextRef context = CGBitmapContextCreate(NULL,
//            imageSize.width,
//            imageSize.height,
//            CGImageGetBitsPerComponent(imageRef),
//            0,
//            colorSpace,
//            bitmapInfo);
//    CGColorSpaceRelease(colorSpace);
//
//    // If failed, return undecompressed image
//    if (!context) return image;
//
//    CGContextDrawImage(context, imageRect, imageRef);
//    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
//
//    CGContextRelease(context);
//
//    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
//    CGImageRelease(decompressedImageRef);
//    return decompressedImage;
//}

@end
