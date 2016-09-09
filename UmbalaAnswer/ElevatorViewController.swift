//
//  ElevatorViewController.swift
//  UmbalaAnswer
//
//  Created by Tien Dat on 9/3/16.
//  Copyright © 2016 Tien Dat. All rights reserved.
//

import UIKit
@objc protocol ElevatorViewControllerDelegate{
    optional func elevatorViewController(homeVC: ElevatorViewController)
    
}
class ElevatorViewController: UIViewController {
    
    var N:Int = 20
    var M:Int = 3
    var elevators:NSMutableDictionary!
    var passengers:NSMutableDictionary!
    var request:[String] = [String]()
    var floor:Int!
    var currentFloor:Int!
    //var request = [Int]()
    var currentStatus = 0
    var mainTimer:NSTimer!
    var delegate:ElevatorViewControllerDelegate!
    
    @IBOutlet weak var goInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passengers = NSMutableDictionary.init(capacity: N)
        elevators = NSMutableDictionary.init(capacity: M)
        
        for  i  in 0..<M {
            
            elevators["elevator\(i)"] = Elevator(maximumFloor: N)

        }
        
        let keys = elevators.allKeys
        var tempID = 1
        for key in keys {

            let elevator = elevators.objectForKey(key) as! Elevator
                elevator.id = tempID
            tempID+=1
        }
        //print elevators
        //print(elevators)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goUp(sender: AnyObject) {
        let keys = elevators.allKeys
        for key in keys
        {
            elevators.objectForKey(key)?.start()

        }
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ElevatorViewController.tick), userInfo: nil, repeats: true)
        
        currentStatus = 1
        
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        UIView.animateWithDuration(0.5) {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    
    func tick (){
        
        //print("\(mainTimer.debugDescription)")
        if(currentStatus == 1 )
        {
            var isEmbarked = false
            //print(request)
            let keys = passengers.allKeys
            for key in keys     {
                let passenger = passengers.objectForKey(key) as! Passenger
                isEmbarked = embarkpassenger(passenger)
                if(isEmbarked){
                    
                    
                    //print("remove passenger at Floor \(passenger.currentFloor)")
                    removePassengerAtLevel(passenger.currentFloor)
                    //[self removePassengerAtLevel:passenger.currentLevel];
                }
            }
            
        } else {
            //have to show a dialog
            print("Elevators are stopped right now. Please click Start.")
        }
    }
    
    @IBAction func goDown(sender: AnyObject) {
        
            if(currentStatus == 1)
            {
                let buttonFloor = arc4random_uniform(UInt32(N))
                let passengerPosition = arc4random_uniform(UInt32(N))
                while(true)
                {
                    
                    if(passengerPosition != buttonFloor)
                    {
                        break;
                    }
                }
                if(passengerPosition != 0)
                {
                    //got a passenger

                    createNewPassenger(Int(buttonFloor), position: Int(passengerPosition))

                }
            } else {
                //have to show a dialog.

                print("Elevators are stopped right now. Please click Start.")
            }
    }
    

    
    @IBAction func btnGoIn(sender: UIButton) {
        if(currentStatus == 1 )
        {
            var isEmbarked = false
            //print(request)
            let keys = passengers.allKeys
            for key in keys     {
                let passenger = passengers.objectForKey(key) as! Passenger
                isEmbarked = embarkpassenger(passenger)
                if(!isEmbarked){
                    
                    
                    //print("remove passenger at Floor \(passenger.currentFloor)")
                    removePassengerAtLevel(passenger.currentFloor)
                    //[self removePassengerAtLevel:passenger.currentLevel];
                }
            }

        } else {
            //have to show a dialog
             print("Elevators are stopped right now. Please click Start.")
        }
    }
    
    func checking(){
        print("current passengers: \(passengers)")
        print("current elevator location: \(elevators.description)")
        let keys = elevators.allKeys
        for key in keys {
            let elevator = elevators.objectForKey(key) as! Elevator
            let passenger = elevator.currentPassenger
            if(elevator.currentFloor == passenger) {
                print("elevator \(elevator.id) reached passenger floor \(passenger)")
                print(passengers)
            }
        }
        
        
    }
    
    func removePassengerAtLevel(floor:Int){
        print("remove passenger at Floor \(floor)")
        
        passengers.removeObjectForKey("passenger\(floor)")
    //[passengers_ removeObjectForKey:INT2STR(level)];
    }

    
    func embarkpassenger(passenger : Passenger) -> Bool {
        var isEmbarked = false
        print("empart passenger")
        let keys = elevators.allKeys
        for key in keys
        {
            let elevator = elevators.objectForKey(key) as! Elevator
            if(elevator.isWaiting && elevator.currentFloor == passenger.currentFloor){
                //this is the elevator that is waiting for the passenger
                elevator.embarkpassenger(passenger.destinationFloor)
                //[elevator embarkPassenger:passenger.destinationLevel];
                isEmbarked = true
                break;
            }
        }
        return isEmbarked
    }
    
    func createNewPassenger(floor:Int, position:Int){
        
        //on the said level we will create a new passenger.
        let passenger = Passenger(currentFloor: floor,destination: position)
        passengers["passenger\(floor)"] =  passenger
        
        //[passengers_ setObject:passenger forKey:INT2STR(level)];
        //goInBtn.titleLabel?.text = "passenger\(floor)"
      
        request.append("passenger\(floor)")
        print("passenger created on \(floor) and destination is \(position)")
        //check the idle elevators and start any of idle towards the passenger.
        checkIdleElevatorsAndMoveToLevel(floor)
    }
    
    func checkIdleElevatorsAndMoveToLevel(floor:Int) {
        let keys = elevators.allKeys
        print("checking for idle elevator")
        for key in keys
        {
            print("iterating")
            let elevator = elevators.objectForKey(key) as! Elevator
                if(elevator.isIdle && !elevator.isWaiting){
                    print(elevator)
                    let passenger = passengers.objectForKey("passenger\(floor)") as! Passenger
                    passenger.isLocked  = true
                    elevator.moveElevatorToLevel(floor)
                                        break;

                    
                }
        }
        print(passengers)
            
    }
    
    
    

    }







