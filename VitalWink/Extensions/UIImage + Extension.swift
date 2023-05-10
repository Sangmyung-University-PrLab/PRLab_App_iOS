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
}
