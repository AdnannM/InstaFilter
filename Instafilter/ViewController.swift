//
//  ViewController.swift
//  Instafilter
//
//  Created by Adnann Muratovic on 11/01/2021.
//  Copyright © 2021 Adnann Muratovic. All rights reserved.
//

import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var itensity: UISlider!
	@IBOutlet var radius: UISlider!
	@IBOutlet var scale: UISlider!
	@IBOutlet var changeFilterTitle: UIButton!
	
	var currentImage: UIImage!
	var contex: CIContext!
	var currentFilter: CIFilter!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Instafilter"
		
		let imageName = "image.png"
		view.backgroundColor = UIColor(patternImage: UIImage(named: imageName)!)
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
		
		contex = CIContext()
		currentFilter = CIFilter(name: "CISepiaTone")
		changeFilterTitle.setTitle("CISepiaTone", for: .normal)
		
		
	}
	
	@objc func importPicture() {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.editedImage] as? UIImage else { return }
		dismiss(animated: true)
		
		currentImage = image
		
		let beginImage = CIImage(image: currentImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		applayProcessing()
	}
	
	@IBAction func changeFilter(_ sender: UIButton) {
		let ac = UIAlertController(title: "Change Filter", message: nil, preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
		
		if let popoverController = ac.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}
		
		present(ac, animated: true)
	}
	
	func setFilter(action: UIAlertAction) {
		guard currentImage != nil else { return }
		guard let actionTitle = action.title else { return }
		
		currentFilter = CIFilter(name: actionTitle)
		
		let beginImage = CIImage(image: currentImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		changeFilterTitle.setTitle(actionTitle, for: .normal)
		applayProcessing()
	}
	
	@IBAction func save(_ sender: Any) {
		guard let image = imageView.image else {
			let ac = UIAlertController(title: "Error", message: "No image selected", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
			return
		}
		
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
	}
	
	@IBAction func itensityChanged(_ sender: Any) {
		applayProcessing()
	}
	
	@IBAction func radiusChanged(_ sender: Any) {
		applayProcessing()
	}
	
	@IBAction func scaleChanged(_ sender: Any) {
		applayProcessing()
	}
	
	func applayProcessing() {
		
		let inputKeys = currentFilter.inputKeys
		
		if inputKeys.contains(kCIInputIntensityKey) {
			currentFilter.setValue(itensity.value, forKey: kCIInputIntensityKey)
		}
		
		if inputKeys.contains(kCIInputRadiusKey) {
			currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
		}
		
		if inputKeys.contains(kCIInputScaleKey) {
			currentFilter.setValue(scale.value * 10, forKey: kCIInputScaleKey)
		}
		
		if inputKeys.contains(kCIInputCenterKey) {
			currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
		}
		
		guard let image = currentFilter.outputImage else {
			return
		}
		
		if let cgImage = contex.createCGImage(image, from: image.extent) {
			let processImage = UIImage(cgImage: cgImage)
			imageView.image = processImage
		}
	}
	
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "Ok", style: .default))
		} else {
			let ac = UIAlertController(title: "Saved", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "Ok", style: .default))
			present(ac, animated: true)
		}
	}
}

