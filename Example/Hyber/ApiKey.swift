//
//  ApiKey.swift
//  Hyber
//
//  Created by Taras on 2/16/17.
//  Copyright © 2017 Incuube. All rights reserved.
//

import UIKit
var clientApiKey = gedApiKeyTest()

func gedApiKeyTest() -> String {
    let def = UserDefaults.standard
    if def.object(forKey: "clientApiKey") == nil {
        return "4fdcbffb-8200-4eeb-a1ea-01124ab1d1ab"
    } else {
        return def.string(forKey: "clientApiKey")!
    }
}


