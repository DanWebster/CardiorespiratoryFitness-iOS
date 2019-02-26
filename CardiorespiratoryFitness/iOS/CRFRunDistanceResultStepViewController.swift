//
//  CRFRunDistanceResultStepViewController.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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

import UIKit

public class CRFRunDistanceResultStepViewModel : RSDResultSummaryStepViewModel {
    
    let usesMetricSystem: Bool = Locale.current.usesMetricSystem
    
    let unitFormatter: LengthFormatter = {
        let unitFormatter = LengthFormatter()
        unitFormatter.unitStyle = .long
        return unitFormatter
    }()
    
    override public var unitText: String? {
        guard let distance = resultAnswer else { return nil }
        if usesMetricSystem {
            return unitFormatter.unitString(fromValue: distance.doubleValue, unit: .meter).localizedUppercase
        } else {
            return unitFormatter.unitString(fromValue: distance.doubleValue, unit: .foot).localizedUppercase
        }
    }
    
    override public var resultText: String? {
        guard let distance = resultAnswer else { return nil }
        return numberFormatter.string(from: distance)
    }
    
    public var resultAnswer : NSNumber? {
        
        let resultStepIdentifier = "run"
        let secResult = taskResult.stepHistory.first { $0.identifier == resultStepIdentifier}
        guard let sectionResult = secResult as? RSDTaskResult
            else {
                return nil
        }
        
        let resultIdentifier = "runDistance"
        guard let result = sectionResult.findAnswerResult(with: resultIdentifier),
            let num = result.value as? RSDJSONNumber,
            let answer = num.jsonNumber()?.doubleValue
            else {
                return nil
        }
        
        return usesMetricSystem ? NSNumber(value: answer) : NSNumber(value: answer * 3.28084)
    }
}

public class CRFRunDistanceResultStepViewController : RSDResultSummaryStepViewController {
    
    public override func instantiateStepViewModel(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepViewPathComponent {
        return CRFRunDistanceResultStepViewModel(step: step, parent: parent)
    }
}
