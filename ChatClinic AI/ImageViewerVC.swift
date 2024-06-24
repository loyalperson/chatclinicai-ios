//
//  ImageViewerVC.swift
//  ChatClinic AI
//
//  Created by charmer on 6/11/24.
//

import UIKit
import ImageViewer_swift
import KFSwiftImageLoader

class ImageViewerVC: UIViewController {
    var photoUrl: String? = nil
    @IBOutlet weak var img_photo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        img_photo.loadImage(urlString: photoUrl!, placeholder: UIImage(systemName: "photo")) {
            (success, error) in
            if success {
                DispatchQueue.main.async {
                   // call your alert in this main thread.
                    self.img_photo.setupImageViewer()
                }
                
            }
            // 'success' is a 'Bool' indicating success or failure.
            // 'error' is an 'Error?' containing the error (if any) when 'success' is 'false'.
        }
    }
    @IBAction func clickBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
