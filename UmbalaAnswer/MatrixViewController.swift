//
//  MatrixViewController.swift
//  UmbalaAnswer
//
//  Created by Tien Dat on 9/3/16.
//  Copyright © 2016 Tien Dat. All rights reserved.
//

import UIKit
import BubbleTransition
import Material
@objc protocol MatrixViewControllerDelegate{
    optional func elevatorViewController(matrixVC: MatrixViewController)
}
class MatrixViewController: UIViewController {
    var matrix: Array<Array <Int>>!
    var n = 8
    var input:Int!
    
    @IBOutlet weak var inputField: UITextField!
    
    
    @IBOutlet weak var toStringlabel: UILabel!
    
    @IBOutlet weak var enterButton: UIButton!
    
    
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    
    @IBOutlet weak var numView: UIView!
    
    let transition = BubbleTransition()
    
    
    
    var delegate: MatrixViewControllerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let inputN = Int(inputLabel.text!)
        matrix = create(n)
        toStringlabel.text = toString()
        
        //inputLabel.text = ""
        rotate()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func create(n: Int) -> Array<Array <Int>> {
        var newMatrix = Array<Array <Int>>()
        
        for i in 0..<n {
            newMatrix.append(Array(count: n, repeatedValue: 0))
            
            for j in 0..<n {
                newMatrix[i][j] = Int(arc4random_uniform(9)) + 1
            }
        }
        
        return newMatrix
    }
    func toString() -> String {
        var str = ""
        
        for i in 0..<matrix.count {
            for j in 0..<matrix[i].count {
                str += String(matrix[i][j]) + " "
            }
            str += "\n"
        }
        
        return str
    }
    func rotate(  degrees: Int = 90) {
        if degrees % 90 != 0 {
            NSException(name: "Disallowed", reason: "Not able to rotate a matrix \(degrees) degrees", userInfo: nil).raise()
        }
        
        var turns = degrees / 90
        
        while turns > 0 {
            turns-=1
            rotate90Degrees()
        }
    }
    
    func rotate90Degrees() {
        for layer in 0..<n/2 {
            let first = layer
            let last = n - 1 - layer
            
            for i in first..<last {
                let offset = i - first
                let top = matrix[first][i]
                
                // top is now left
                matrix[first][i] = matrix[last - offset][first]
                // left is now bottom
                matrix[last - offset][first] = matrix[last][last - offset]
                // bottom is now right
                matrix[last][last - offset] = matrix[i][last]
                // right is now top
                matrix[i][last] = top
            }
        }
    }
    
    
    

    

    
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        UIView.animateWithDuration(0.5) {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }

    @IBAction func makeRotate(sender: UIBarButtonItem) {
        UIView.animateWithDuration(1) {
           self.rotate()
            self.toStringlabel.text = self.toString()
            self.view.setNeedsLayout()
        }
        
    }
    

}
extension MatrixViewController: UICollectionViewDataSource, UICollectionViewDelegate{
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matrix.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return matrix.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoCell", forIndexPath: indexPath) as! NoCell
        cell.numLabel.text = String(matrix[indexPath.section][indexPath.row])
        return cell
        
    }
    


}





