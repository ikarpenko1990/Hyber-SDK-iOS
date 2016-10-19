//
//  UIFont+Bold.swift
//  Hyber
//
//  Created by Vitalii Budnik on 4/22/16.
//
//

import Foundation
import UIKit

internal extension UIFont {
  
  internal var boldFont: UIFont {
    
    let fontDescriptor = self.fontDescriptor()
    let boldFontDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
    let boldFont = UIFont(descriptor: boldFontDescriptor!, size: fontDescriptor.pointSize)
    return boldFont
    
  }
  
}
