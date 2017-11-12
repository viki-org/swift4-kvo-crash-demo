//
//  ViewController.swift
//  TrySwift4KVO
//
//  Created by Thongchai Kolyutsakul on 16/10/17.
//  Copyright © 2017 Hlung. All rights reserved.
//

import UIKit

@objcMembers class Kid: NSObject {
  dynamic var name: String
  dynamic var age: Int

  init(name: String, age: Int) {
    self.name = name
    self.age = age
  }

  func increaseAge() {
    age += 1
    print("increase age to: \(age)")
  }

  deinit {
    print("Deinit: \(self.description)")
  }

  override var description: String {
    return "Kid name:\(name) age:\(age)"
  }
}

@objcMembers class KidGroup: NSObject {
  var observation: NSKeyValueObservation?
  dynamic var kid1: Kid?

  func setupObservation() {
    observation = observe(\.kid1) { object, change in
      print("Observed a change to \(String(describing: object.kid1))")
    }
  }

  deinit {
    // these doesn't help...
    observation?.invalidate()
    observation = nil

    print("Deinit: KidGroup")
  }
}

class ViewController: UIViewController {

  var observation: NSKeyValueObservation?
  var kidGroup: KidGroup?

  lazy var goodButton: UIButton = {
    let button = UIButton()
    button.setTitle("Good button", for: .normal)
    button.backgroundColor = UIColor.lightGray
    button.addTarget(self, action: #selector(ViewController.didTapButton(_:)), for: .touchUpInside)
    return button
  }()

  lazy var crashButton: UIButton = {
    let button = UIButton()
    button.setTitle("Crash button", for: .normal)
    button.backgroundColor = UIColor.red
    button.addTarget(self, action: #selector(ViewController.didTapButton(_:)), for: .touchUpInside)
    return button
  }()

  @objc func didTapButton(_ button: UIButton) {
    print("--- Tapped \(button.title(for: .normal) ?? "-") ---")
    kidGroup = KidGroup()
    kidGroup?.kid1 = Kid(name: "A kid", age: 3)
    kidGroup?.setupObservation()

    if button == goodButton {
      // clear observation before destroying kidGroup to avoid crash on iOS 10 and below
      kidGroup?.observation?.invalidate()
    }

    kidGroup?.kid1 = Kid(name: "A kid", age: 4)

    // if you didn't invalidate the observation, it will crash at this point
    self.kidGroup = nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    goodButton.frame = CGRect(x: 20, y: 100, width: 200, height: 50)
    view.addSubview(goodButton)

    crashButton.frame = CGRect(x: 20, y: 200, width: 200, height: 50)
    view.addSubview(crashButton)
  }

}

