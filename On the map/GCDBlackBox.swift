//
//  GCDBlackBox.swift
//  On the map
//
//  Created by Nitish on 28/12/16.
//  Copyright © 2016 Nitish. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain( updates: @escaping() -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
