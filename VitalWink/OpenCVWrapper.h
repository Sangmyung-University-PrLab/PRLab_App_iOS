//
//  OpenCVWrapper.h
//  VitalWink
//
//  Created by 유호준 on 2023/05/11.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface OpenCVWrapper: NSObject

+ (NSArray*)skinSegmentation: (const UIImage*) image;

@end
#endif /* OpenCVWrapper_h */
