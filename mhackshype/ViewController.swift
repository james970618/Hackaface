//
//  ViewController.swift
//  mhackshype
//
//  Created by James on 2016/10/8.
//  Copyright © 2016 Yifan Jiang, Xu Han, Yixiao Peng, Zhaojie Gong. All rights reserved.
//

import UIKit

let keys : [String] = ["anger", "fear", "surprise", "contempt", "disgust", "happiness", "neutral", "sadness"]
var scores : [JSON] = []
var originalScore : JSON? = nil
var theScores : [Double] = []
var photos : [UIImage] = []
var originalImage : UIImage? = nil;
var hasTakenOriginalPhoto : Bool = false;
var hasProcessedOriginalScore = false;
func -(first : JSON, second : JSON) -> Double {
    var returnResult : Double = 0;
    for key in keys {
        if ((first[key] != nil) && (second[key] != nil)) {
            print("\(first[key])-\(second[key])")
//            print((first[key]-second[key]))
//            print(pow((Double(first[key]) - Double(second[key])),2))
//            print(first[key].rawValue)
//            print(second[key].rawValue)
//            print(((first[key].rawValue as! Double)-(second[key].rawValue as! Double)))
            returnResult += pow(((first[key].rawValue as! Double)-(second[key].rawValue as! Double)),2)
        }
    }
//    returnResult = 100 - returnResult*50
    returnResult = 100*(1-sqrt(returnResult/2.0))
    print(returnResult)
    return returnResult;
}

func analyzeEmotion(json: JSON) -> String {
    var highestValue = 0.0;
    var highestKey : String = "Null";
    for key in keys {
        if let value = json[key].rawValue as? Double {
            if key != "neutral" {
                if value > highestValue {
                    highestValue = value
                    highestKey = key
                }
            }
        }
    }
    return "Your \(highestKey) : \(round(highestValue*100))"
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override var prefersStatusBarHidden: Bool{
        return true
    }
    var blackBlock = UIView(frame: CGRect(origin: CGPoint(x: 350,y: 640), size: CGSize(width: 50, height: 50 )))
    var blackBlockAdded = false;
    
    
//    @IBAction func addBlackBlock(_ sender: UITapGestureRecognizer) {
//        if !blackBlockAdded {
//            if sender.state == .began {
//                view.addSubview(blackBlock);
//            }
//            blackBlockAdded = true;
//        }
//    }
    @IBOutlet weak var scoreLabel: UILabel!
    
    func requestEmotion(by image : UIImage) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.projectoxford.ai/emotion/v1.0/recognize")! as URL)
        let session = URLSession.shared
        request.httpMethod = "POST"
        var body : Data? = nil;
        if hasTakenOriginalPhoto {
            body = UIImageJPEGRepresentation(image, 0.05)
        } else {
            body = UIImageJPEGRepresentation(image, 0.05)
        }
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.addValue("4c46be9fd2034a038fc8487634683123", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = session.uploadTask(with: request as URLRequest, from: body, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
//            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            let json = JSON(data: data! as Data)
            print(json)
            if hasTakenOriginalPhoto&&hasProcessedOriginalScore{
                scores.append(json[0]["scores"])
                theScores.append(originalScore! - scores.last!)
                self.scoreLabel.text = analyzeEmotion(json: json[0]["scores"]);
                if #available(iOS 10.0, *) {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showScoreboard", sender: self.scoreBoard)
                    }
//                    DispatchQueue.main.async {
//                        UIView.animate(withDuration: 0.4, animations: {
//                            self.scoreLabel.alpha = 1.0;
//                        })
//                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
//                            UIView.animate(withDuration: 0.4, animations: {
//                                self.scoreLabel.alpha = 0.0;
//                            })
//                        })
//                    }
                } else {
//                    UIView.animate(withDuration: 0.4, animations: {
//                        self.scoreLabel.alpha = 0.0;
//                    })
                }
            } else{
                originalScore = json[0]["scores"]
                hasProcessedOriginalScore = true;
            }
        })
        task.resume()
    }
    
    func requestByURL(url: String) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.projectoxford.ai/emotion/v1.0/recognize")! as URL)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        //        let body = ["url": "http://emotionsinmotion.azurewebsites.net/samples/dg06.jpg"] as Dictionary<String, String>
                let body = ["url": url] as Dictionary<String, String>
        
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("4c46be9fd2034a038fc8487634683123", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        
                let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                    print("Response: \(response)")
                    let json = JSON(data: data! as Data)
                    print(json)
                })
        
        task.resume()
    }
    
    @IBAction func request(_ sender: UIButton) {
        requestEmotion(by: originalImage!);
        
//        requestByURL(url: "http://emotionsinmotion.azurewebsites.net/samples/dg06.jpg")
    }
    
    
    
//    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    var isShowingAfterImage : Bool = false;
    var croppedImage : UIImage? = nil{
        didSet{
            myImageView.image = croppedImage;
        }
    }
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet var loadingView: UIView!
    func showLoadingView() {
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.loadingView)
        let bottomConstraint = self.loadingView.bottomAnchor.constraint(equalTo: self.takePhotoButton.topAnchor)
        let leftConstraint = self.loadingView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        let rightConstraint = self.loadingView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        let heightConstraint = self.loadingView.heightAnchor.constraint(equalToConstant: 30)
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.alpha = 0
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.loadingView.alpha = 1
        }
    }
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBAction func onChallenge(_ sender: UIButton) {
        prepareForPickingImage(sender: sender)
    }
    func prepareForPickingImage(sender: UIView) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.showCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { (alert) in
            self.showAlbum()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            if sender == self.takePhotoButton && originalImage != nil {
                hasTakenOriginalPhoto = true;
                if originalScore != nil {
                    hasProcessedOriginalScore = true;
                }
            }
        }))
        actionSheet.popoverPresentationController?.sourceView = sender;
        self.present(actionSheet, animated: true) {
        }
        
    }
    @IBAction func onTakePhoto(_ sender: UIButton) {
        hasTakenOriginalPhoto = false;
        hasProcessedOriginalScore = false;
        prepareForPickingImage(sender: sender)
    }
//    @IBAction func onButton(_ sender: UIButton) {
//        if isShowingAfterImage {
//            myImageView.image = originalImage;
//        } else {
//            if croppedImage == nil {
//                blackBlock(in: originalImage, at: CGRect(x: 1000, y: 1000, width: 1000, height: 1000))
//            }
//            myImageView.image = croppedImage;
//        }
//        isShowingAfterImage = !isShowingAfterImage;
//    }
    
//    func blackBlock(in rgbaImage : UIImage?, at rectangle: CGRect) {
//        var index : Int;
//        var myRGBA = RGBAImage(image: rgbaImage!);
//        if  myRGBA != nil {
//            for y in Int(rectangle.minY)..<Int(rectangle.maxY){
//                for x in Int(rectangle.minX)..<Int(rectangle.maxX) {
//                    index = y*myRGBA!.width + x;
//                    myRGBA!.pixels[index].blue = 0;
//                    myRGBA!.pixels[index].red = 0;
//                    myRGBA!.pixels[index].green = 0;
//                }
//            }
//            croppedImage = myRGBA!.toUIImage();
//        }
//    }
    @IBAction func onShare(_ sender: UIBarButtonItem) {
        shareOriginalPhoto()
    }
    @IBAction func onShowAnswer(_ sender: UIBarButtonItem) {
        myImageView.image = originalImage
    }
    
    @IBOutlet weak var showAnswer: UIBarButtonItem!
    @IBOutlet weak var share: UIBarButtonItem!
    @IBOutlet weak var scoreBoard: UIButton!
    @IBOutlet weak var challenge: UIButton!
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        if !hasTakenOriginalPhoto {
            cameraPicker.allowsEditing = true;
            cameraPicker.setEditing(true, animated: true)
        } else {
            cameraPicker.setEditing(false, animated: false)
        }
        self.present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        if !hasTakenOriginalPhoto {
            cameraPicker.allowsEditing = true;
            cameraPicker.setEditing(true, animated: true)
        } else {
            cameraPicker.setEditing(false, animated: false)
        }
        self.present(cameraPicker, animated: true, completion: nil)
    }
//    @IBAction func onShare(_ sender: UIButton) {
//        let actionSheet = UIAlertController(title: "Save or Share", message: nil, preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Save to photo library", style: .default, handler: { (alert) in
//            if let image = self.myImageView.image{
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//            }
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Share", style: .default, handler: { (alert) in
//            self.share();
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(actionSheet, animated: true, completion: nil)
//    }
//    @IBAction func onSave(_ sender: UIButton) {
//        save();
//    }
    
    func save() {
        if let image = originalImage{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    func shareOriginalPhoto() {
        if let image = UIImageJPEGRepresentation(originalImage!, 0.5) {
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if hasTakenOriginalPhoto {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                requestEmotion(by: image)
                photos.append(image);
            }
        } else {
            photos = []
            scores = []
            theScores = []
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                requestEmotion(by: image);
                originalImage = image;
            }
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
                croppedImage = image;
                if picker.sourceType == .camera {
                save();
                }
            }
            enableButtons()
            hasTakenOriginalPhoto = true;
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        if originalImage != nil {
            hasTakenOriginalPhoto = true
            if originalScore != nil {
                hasProcessedOriginalScore = true
            }
        }
    }
    
    func enableButtons() {
        challenge.isEnabled = true;
        showAnswer.isEnabled = true;
        scoreBoard.isEnabled = true;
        share.isEnabled = true;
    }
    
    func disableButtons() {
        challenge.isEnabled = false;
        showAnswer.isEnabled = false;
        scoreBoard.isEnabled = false;
        share.isEnabled = false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scoreLabel.alpha = 0.0;
        if !hasTakenOriginalPhoto {
            disableButtons();
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !hasTakenOriginalPhoto {
            onTakePhoto(takePhotoButton);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToImage(_ sender: UIStoryboardSegue){
        
    }

}

