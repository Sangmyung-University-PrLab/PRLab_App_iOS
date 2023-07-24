//
//  UIImage + Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/10.
//

import Foundation
import UIKit
import CoreMedia
extension UIImage{
    convenience init(sampleBuffer: CMSampleBuffer){
        guard let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let _ = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            self.init()
            return
        }
    
        CVPixelBufferLockBaseAddress(videoPixelBuffer, CVPixelBufferLockFlags.readOnly)
        let baseAddr = CVPixelBufferGetBaseAddress(videoPixelBuffer)
        let bytePerRow = CVPixelBufferGetBytesPerRow(videoPixelBuffer)
        let width = CVPixelBufferGetWidth(videoPixelBuffer)
        let hegith = CVPixelBufferGetHeight(videoPixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext(data: baseAddr, width: width, height: hegith, bitsPerComponent: 8, bytesPerRow: bytePerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        guard let quarzImage = context?.makeImage() else {
            self.init()
            return
        }
        
        CVPixelBufferUnlockBaseAddress(videoPixelBuffer, CVPixelBufferLockFlags.readOnly)
        self.init(cgImage: quarzImage)
    }
    var cvPixelBuffer: CVPixelBuffer?{
        var pixelBuffer: CVPixelBuffer? = nil
        let options: [NSObject: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ]
        
        _ = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext(data: pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: bitmapInfo)
        
        context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    func drawRect(_ rect: CGRect) -> UIImage{
        UIGraphicsBeginImageContext(self.size)
        guard let ctx = UIGraphicsGetCurrentContext() else{
            return UIImage()
        }
        
        self.draw(at: .zero)
        ctx.setStrokeColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        ctx.setLineWidth(5)
        ctx.addRect(rect)
        ctx.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
