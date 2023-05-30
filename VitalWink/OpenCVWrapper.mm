//
//  OpenCVWrapper.m
//  VitalWink
//
//  Created by 유호준 on 2023/05/11.
//

#import "OpenCVWrapper.h"
#include <opencv2/imgcodecs/ios.h>
#include <opencv2/opencv.hpp>
using namespace cv;

@implementation OpenCVWrapper

/// 피부 분할 후 픽셀들의 평균을 낸 BGR  값
+ (NSArray<NSNumber *>* _Nonnull)skinSegmentation:(const UIImage * _Nonnull)image{
    Mat bgraMat, bgrMat, ycrcbMat, mask;
    Mat planes[3];
    int bSum = 0, gSum = 0, rSum = 0;
    
    UIImageToMat(image, bgraMat);
    cvtColor(bgraMat, bgrMat, COLOR_BGRA2BGR);
    [self createSkinMask:bgrMat :mask];
    bgrMat.setTo(0, mask == 0);
    int nPixels = bgrMat.rows * bgrMat.cols;
    
    for(int i = 0; i < nPixels; i++){
        bSum += bgrMat.data[3*i];
        gSum += bgrMat.data[3*i + 1];
        rSum += bgrMat.data[3*i + 2];
    }
    
    return [[NSArray<NSNumber*> alloc] initWithObjects:[[NSNumber alloc] initWithInt:bSum / nPixels],
            [[NSNumber alloc] initWithInt:gSum / nPixels],
            [[NSNumber alloc] initWithInt:rSum / nPixels], nil];
}

+ (void) createSkinMask: (InputArray)src: (OutputArray)dst {
    /** Skin filtering based on YCbCr color space */
    cv::Mat rgb = src.getMat();
    cv::Mat mask;
    cv::Mat ycrcb;

    cv::cvtColor(rgb, ycrcb, cv::COLOR_BGR2YCrCb);
    cv::inRange(ycrcb, cv::Scalar(0,77 ,133), cv::Scalar(235, 127, 173), mask);
    mask.setTo(1, mask == 255);
    
    mask.copyTo(dst);
}

@end
