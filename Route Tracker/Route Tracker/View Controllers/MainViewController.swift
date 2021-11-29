//
//  MainViewController.swift
//  Route Tracker
//
//  Created by Leo Malikov on 29.11.2021.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {

    @IBOutlet weak var toMapButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        guard UIImagePickerController.isCameraDeviceAvailable(.front) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let destination = segue.destination as? MapViewController,
            let image = loadImage()
        else { return }
        destination.userImage = image
    }

}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var data = [String: Any]()
        info.forEach {
            data[$0.rawValue] = $1
        }
        let image = extractImage(from: data)?.pngData()
        saveImage(image: image)
        picker.dismiss(animated: true)
    }
    
    private func extractImage(from data: [String: Any]) -> UIImage? {
        if let image = data[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            return image
        } else if let image = data[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            return image
        } else {
            return nil
        }
    }
    
    private func saveImage(image: Data?) {
        guard
            let image = image,
            let imageUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("UserImage.png")
        else { return }
        
        FileManager.default.createFile(atPath: imageUrl.path, contents: image)
    }
    
    private func loadImage() -> UIImage? {
        guard
            let imageUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("UserImage.png"),
            let image = UIImage(contentsOfFile: imageUrl.path)
        else {
            return nil
        }
        return image
    }
    
}
