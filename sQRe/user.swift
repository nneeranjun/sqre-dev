//
//  user.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import Foundation
class User {
    var name: String?
    var email: String?
    var phone_number: String?
    //Constructor
    init(name: String, email: String, phone_number: String) {
        self.name = name;
        self.email = email;
        self.phone_number = phone_number;
    }
    
    
    
}
