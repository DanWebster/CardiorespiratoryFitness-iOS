//
//  CRFCameraSettings.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2017-2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import AVFoundation
import JsonModel
import Research

extension SerializableResultType {
    public static let cameraSettings: SerializableResultType = "cameraSettings"
}

/// The camera settings to use for the heart rate recorder.
public struct CRFCameraSettings : Codable, SerializableResultData, RSDArchivable, Equatable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case identifier, serializableType = "type", frameRate, focusLensPosition, exposureDuration, iso, whiteBalance
    }
    
    /// The identifier associated with these Camera settings.
    public var identifier: String = "cameraSettings"
    
    /// The result type is hardcoded as camera settings.
    public let serializableType: SerializableResultType = .cameraSettings
    
    /// The start date for these camera settings. This is a required property of `RSDResult`
    /// but is ignored by the configuration.
    public var startDate: Date = Date()
    
    /// The end date for these camera settings. This is a required property of `RSDResult`
    /// but is ignored by the configuration.
    public var endDate: Date = Date()
    
    /// The frame rate for taking video. Default = `60`
    public var frameRate: Int = CRFSupportedFrameRates.first!
    
    /// Desired lens focal length. This number should be between `0.0 - 1.0` where "nearest" is `0`
    /// and "farthest" is `1.0`. Default = `1.0`
    public var focusLensPosition: Float = 1.0
    
    /// The exposure duration in seconds.
    ///
    /// Note that changes to this property may result in changes to `activeVideoMinFrameDuration`
    /// and/or `activeVideoMaxFrameDuration`. Default = `1/120`
    public var exposureDuration: TimeInterval = 1.0 / 120.0
    
    /// This property returns the sensor's sensitivity to light by means of a gain value applied to
    /// the signal.
    ///
    /// Only ISO values between `minISO` and `maxISO` of the current device format are supported.
    /// Higher values will result in noisier images.
    ///
    /// If the settings requests an ISO that is outside the bounds of the minimum and maximum,
    /// then the actual value set will be bound by those values. Default = `60`
    public var iso: Float = 60
    
    /// White balance is set using the temperature and tint. Default = (temperature: 5200K, tint: 0)
    public var whiteBalance : WhiteBalance = WhiteBalance()
    
    /// Codable struct that can be converted to `AVCaptureDevice.WhiteBalanceTemperatureAndTintValues`.
    public struct WhiteBalance : Codable, Equatable {
        
        /// The temperature setting.
        public var temperature: Float = 5200
        
        /// The tint setting.
        public var tint: Float = 0
        
        fileprivate enum CodingKeys: String, CodingKey {
            case temperature
            case tint
        }
    }
    
    /// Default initializer
    public init() {
    }
    
    public func deepCopy() -> CRFCameraSettings {
        self
    }
    
    /// Initialize the struct using a step result that maps to a collection.
    public init(stepResult: CollectionResult) {
        var wb = WhiteBalance()
        for result in stepResult.children {
            let identifier = result.identifier.components(separatedBy: ".")
            if let value = (result as? AnswerResult)?.value as? NSNumber,
                let key = CodingKeys(rawValue: identifier.first!) {
                switch key {
                case .focusLensPosition:
                    self.focusLensPosition = value.floatValue
                case .exposureDuration:
                    self.exposureDuration = value.doubleValue
                case .iso:
                    self.iso = value.floatValue
                case .whiteBalance:
                    if let wbKey = WhiteBalance.CodingKeys(rawValue: identifier.last!) {
                        switch wbKey {
                        case .temperature:
                            wb.temperature = value.floatValue
                        case .tint:
                            wb.tint = value.floatValue
                        }
                    }
                default:
                    break
                }
            }
        }
        self.whiteBalance = wb
    }
    
    /// Build the archiveable or uploadable data for this result.
    public func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)? {
        let data = try self.rsd_jsonEncodedData()
        let filename = "\(RSDFileResultUtility.filename(for: identifier)).json"
        let manifest = RSDFileManifest(filename: filename, timestamp: self.startDate, contentType: "application/json", identifier: self.identifier, stepPath: nil)
        return (manifest, data)
    }
}
