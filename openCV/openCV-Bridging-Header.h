//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifndef openCV_Bridging_Header_h
#define openCV_Bridging_Header_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Detector: NSObject

- (id)init;
- (UIImage *)recognizeFace:(UIImage *)image;

@end

#endif /* openCV_Bridging_Header_h */