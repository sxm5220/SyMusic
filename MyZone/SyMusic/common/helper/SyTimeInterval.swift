//
//  SyTimeInterval.swift
//  wwsq
//
//  Created by sxm on 2017/7/16.
//  Copyright © 2017年 wwsq. All rights reserved.
//

import UIKit

public typealias executeTimerClosure = ()->()

//将closure封装成一个对象
private class ClosureObject<T> {
    let closure: T?
    init (closure: T?) {
        self.closure = closure
    }
}



extension TimeInterval {
    
    var durationText:String {
        if self.isNaN || self.isInfinite {
            return "00:00"
        }
        let hours = Int(self.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes = Int(self.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        if hours > 0{
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        }else{
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

public extension Timer {
    
    class func getFormatTime(_ timeInterval: TimeInterval) -> String {
        return String(format: "%02d: %02d", Int(timeInterval) / 60, Int(timeInterval) % 60)
    }

    class func getTimeInterval(_ formatTime: String) -> TimeInterval {
        let minSec = formatTime.components(separatedBy: ":")
        if minSec.count != 2 {
            return 0
        }
        let min = TimeInterval(minSec[0]) ?? 0.0
        let sec = TimeInterval(minSec[1]) ?? 0.0
        return min * 60.0 + sec
    }
    
    class func xb_scheduledTimerWithTimeInterval(_ timeInterval: TimeInterval,
                                                        isRepeat: Bool,
                                                        closure: executeTimerClosure?) -> Timer {
        let block = ClosureObject<executeTimerClosure>(closure: closure)
        let timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                         target: self,
                                         selector: #selector(xb_executeTimerBlock),
                                         userInfo: block,
                                         repeats: isRepeat)
        return timer
    }
    
    class func xb_scheduledTimerWithTimeInterval(_ timeInterval: TimeInterval,
                                                        closure: executeTimerClosure?) -> Timer {
        return xb_scheduledTimerWithTimeInterval(timeInterval,
                                                 isRepeat: false,
                                                 closure: closure)
    }
    
    @objc class func xb_executeTimerBlock(_ timer: Timer) {
        if let block = timer.userInfo as? ClosureObject<executeTimerClosure> {
            if let closure = block.closure {
                closure()
            }
        }
    }
}
