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

+ (NSArray<NSNumber *>* _Nonnull)skinSegmentation:(const UIImage * _Nonnull)image{
    Mat bgraMat, bgrMat, ycrcbMat, mask;
    Mat planes[3];
    
    UIImageToMat(image, bgraMat);
    cvtColor(bgraMat, bgrMat, COLOR_BGRA2BGR);
    [self createSkinMask:bgrMat :mask];
    bgrMat.setTo(0, mask == 0);
    NSMutableArray *bgrArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < bgrMat.rows * bgrMat.cols * bgrMat.channels(); i++){
        [bgrArray addObject:[NSNumber numberWithUnsignedChar:bgrMat.data[i]]];
    }
    return bgrArray;
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
