//
//  File.swift
//  UmbalaAnswer
//
//  Created by Tien Dat on 9/6/16.
//  Copyright © 2016 Tien Dat. All rights reserved.
//

import Foundation

@objc protocol elvatorDelegate{
    optional func elevatorLevelChanged(elevator:Elevator)
    optional func elevatorStarted(elevator:Elevator)
    optional func elevatorReached(elevator:Elevator)
    optional func elevatorPassengerDisembarked(elevator:Elevator)
    optional func elevatorStartCalled(elevator:Elevator)
    optional func elevatorPauseCalled(elevator:Elevator)
    optional func elevatorResetCalled(elevator:Elevator)
}
class Elevator :NSObject{
    var id:Int!
    var isGoingUp:Bool = false
    var currentFloor:Int = 0
    var currentPassenger:Int = 0
    var currentDirection:Int = 0 // 0 stay 1 up 2 down
    var isIdle:Bool = true
    var reqFloor:Int = 0
    var isStarted:Bool = false
    var timer:NSTimer!
    var isWaiting:Bool = false
    var delegate: elvatorDelegate?
    var maxFloor:Int = 4

  
    
    init(maximumFloor maxFloor:Int) {
        self.maxFloor = maxFloor
    }
    
    func start(){
        print(reqFloor)
        print(isIdle)
        if((timer) != nil){
            timer.invalidate()
            timer = nil
        }
        if(isIdle){
            
        }
        if(isStarted){
            
        }
        if(!isIdle && reqFloor != 0  && currentPassenger == 0)
        {
            
            moveElevatorToLevel(reqFloor)
        }
        //4- moving with passenger
        if(!isIdle && reqFloor != 0 && currentPassenger != 0 && reqFloor != currentFloor)
        {
            moveElevatorToLevel(reqFloor)
            
        }
        
        //5- disembarking passenger
        if(!isIdle && reqFloor != 0 && reqFloor == currentPassenger && currentPassenger == currentFloor)
        {
            //there was a passenger in the elevator. have to disemabrk him.
            print("start disembark")
            timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(Elevator.disembark(_:)), userInfo: nil, repeats: true)
            
        }
        isStarted = true
        delegate?.elevatorStartCalled!(self)
    }
    
    func pause(){
       
            if((timer) != nil)
            {
                timer.invalidate()
                timer = nil
            }
            
            isStarted = false
            delegate?.elevatorPauseCalled!(self)
        
    }
    
    func reset(){
        
        if((timer) != nil)
        {
            timer.invalidate()
            timer = nil
        }
            currentFloor = 1;
            currentPassenger = 0;
            isIdle = true
            currentDirection = 0
            isWaiting = false
            isStarted = false
            delegate?.elevatorResetCalled!(self)
        
    }
    
    func moveUp( timer: NSTimer) {
        let requiredFloor = Int((timer.userInfo?.objectForKey("level")?.intValue)!)
        print("elevator \(id) moving up to: \(currentFloor + 1)")
        if(currentFloor < requiredFloor) {
            currentFloor = currentFloor + 1
            delegate?.elevatorLevelChanged!(self)
        }
        
        if(currentFloor == requiredFloor){
            self.timer.invalidate()
            currentDirection = 0
            if(currentPassenger != 0) {
                print("disembarking ")
                self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(Elevator.disembark(_:)), userInfo: nil, repeats: true)
            } else {
                isIdle = true
                isWaiting = true
                reqFloor = 0
                delegate?.elevatorReached!(self)
            }
        }
        
    }
    
    func moveDown( timer:NSTimer) {
        //int requiredLevel = [[timer.userInfo objectForKey:@"level"] intValue];
        let requiredFloor = Int((timer.userInfo?.objectForKey("level")?.intValue)!)
        print("elevator \(id) moving down to: \(currentFloor - 1)")
        if(currentFloor > requiredFloor ) {
            currentFloor = currentFloor - 1
            delegate?.elevatorLevelChanged!(self)
        }
    
        if(currentFloor == requiredFloor) {
            self.timer.invalidate()
            currentDirection = 0
            if(currentPassenger != 0){
                print("disembarking ")
                self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(Elevator.disembark(_:)), userInfo: nil, repeats: true)
                
            } else {
                isIdle = true
                isWaiting = true
                reqFloor = 0
                delegate?.elevatorReached!(self)
            }
        }
    }
    
    func disembark( timer:NSTimer)
    {
        currentPassenger = 0
        self.timer.invalidate()
        //timer = nil
        isIdle = true
        print("disembarked ")
        delegate?.elevatorPassengerDisembarked!(self)
    }
    
    func embarkpassenger(passenger : Int){
        currentPassenger = passenger
        moveElevatorToLevel(passenger)
    }

    
    func moveElevatorToLevel(level:Int){
        print("elevator \(id) current floor is \(currentFloor)")
        print("req floor is \(level)")
        reqFloor = level
        if(currentFloor == level){
            print("Same")
            reqFloor = 0;
            currentPassenger = 0;
            isWaiting = true;
            currentDirection = 0;
            delegate?.elevatorReached!(self)

            return;
        }
        
        if((timer) != nil)
        {
            timer.invalidate()
            timer = nil
        }
        let params  = NSDictionary(object: level, forKey: "level")
        //print("params: \(params)")
        
        if(currentFloor < level)
        {
            currentDirection = 1
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(Elevator.moveUp(_:)), userInfo: params, repeats: true)
            print("moving up")

        } else {
            currentDirection = 2
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(Elevator.moveDown(_:)), userInfo: params, repeats: true)
            print("moving down")
            
        }
        isIdle = false
        isWaiting = false
        delegate?.elevatorStarted!(self)
    }
}

class Passenger: NSObject {
    var currentFloor:Int!
    var destinationFloor:Int!
    var isLocked:Bool = false
    
    init(currentFloor x:Int, destination y:Int){
        currentFloor = x
        destinationFloor = y
    }
}