//
//  VideoWriter.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/26.
//

import Foundation
import AVFoundation
import AssetsLibrary
import CoreMedia
class VideoWriter{
    
    private var fileWiter: AVAssetWriter!
    private var videoInput: AVAssetWriterInput!
    
    init(fileURL: URL, width: Int, height: Int, channels: Int){
        fileWiter = try? AVAssetWriter(url: fileURL, fileType: .mp4)
        let videoOutputSetting: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSetting)
        videoInput.expectsMediaDataInRealTime = true
        if fileWiter.canAdd(videoInput){
            fileWiter.add(videoInput)
        }
    }
    
    func write(buffer: CMSampleBuffer) async{
        if CMSampleBufferDataIsReady(buffer){
            switch fileWiter.status{
            case .unknown:
                await Task.yield()
                let startTime = CMSampleBufferGetPresentationTimeStamp(buffer)
                fileWiter.startWriting()
                fileWiter.startSession(atSourceTime: startTime)
            case .writing:
                await Task.yield()
                if videoInput.isReadyForMoreMediaData{
                    videoInput.append(buffer)
                }
            default:
                return
            }
        }
    }

    func cancel(){
        fileWiter.cancelWriting()
    }

    func finish() async{
        await fileWiter.finishWriting()
    }
}
