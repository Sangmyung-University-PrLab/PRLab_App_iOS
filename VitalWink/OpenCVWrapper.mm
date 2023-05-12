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

+ (UIImage*)skinSegmentation:(const UIImage *)image{
    Mat bgraMat, bgrMat, ycrcbMat, mask;
    Mat planes[3];
    
    UIImageToMat(image, bgraMat);
    cvtColor(bgraMat, bgrMat, COLOR_BGRA2BGR);
    [self createSkinMask:bgrMat :mask];
    split(bgrMat, planes);

    planes[0].setTo(0, mask==0);
    planes[1].setTo(0, mask==0);
    planes[2].setTo(0, mask==0);

    merge(planes, 3, bgrMat);

    return MatToUIImage(bgrMat);
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
