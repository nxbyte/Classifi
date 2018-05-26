/*
 Developer : Warren Seto
 Classes   : UIRoundedButton
 Project   : Classifi App (v1)
 */

import UIKit

class UIRoundedButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.customize()
    }
    
    func customize () {
        self.backgroundColor = UIColor.lightGray
        self.layer.cornerRadius = 15
        self.titleLabel?.textColor = UIColor.white
        self.titleLabel?.textAlignment = .center
    }
    
}
