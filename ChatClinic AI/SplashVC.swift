//
//  ViewController.swift
//  ChatClinic AI
//
//  Created by charmer on 6/3/24.
//

import UIKit

class SplashVC: UIViewController {
    var timer:Timer? = nil
    var counter:Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    @objc func update() {
        self.counter -= 1
        if self.counter == 0 {
            self.cancelTimer()
            goToLoginPage()
        }
    }
    func goToLoginPage() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelTimer()
    }
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

}

