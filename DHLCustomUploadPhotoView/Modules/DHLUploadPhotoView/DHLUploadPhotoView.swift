//
//  UploadPhotoView.swift
//  DHLCustomUploadPhotoView
//
//  Created by Daniel Hernandez on 23/6/25.
//

import Foundation
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

public class DHLUploadPhotoView: UIView {
    
    @IBOutlet weak var containerView: DHLCustomDashedView!
    @IBOutlet weak var attachPhotoLabel: UILabel!
    @IBOutlet public weak var attachedPhotoImageView: UIImageView!
    @IBOutlet weak var attachPhotoButton: UIButton!
    
    private var parent: UIViewController?
    private var showDelete: Bool = true
    
    var pickedImagePath: URL?

    public override init(frame: CGRect) {

        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {

        backgroundColor = .clear
        
        let bundle = Bundle(for: DHLUploadPhotoView.self)

        if let xibView = bundle.loadNibNamed("DHLUploadPhotoView", owner: self, options: nil)?.first as? UIView {

            xibView.frame = self.bounds
            xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(xibView)

            commonInit()
        }
    }

    public override func awakeFromNib() {

        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {
        
        self.accessibilityViewIsModal = true
        attachPhotoLabel.isAccessibilityElement = false
        
        containerView.cornerRadius = 8
        containerView.dashWidth = 1.5
        containerView.dashLength = 6
        containerView.betweenDashesSpace = 3
        
        attachPhotoLabel.text = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
    }

    public func setUp(parent: UIViewController, font: UIFont = .systemFont(ofSize: 14), customTintColor: UIColor = .blue, image: UIImage? = nil, showDelete: Bool = true) {
        self.parent = parent
        self.showDelete = showDelete
        
        attachPhotoLabel.font = font
        containerView.dashColor = customTintColor
        
        pickedImagePath = nil
        attachedPhotoImageView.image = nil
        
        containerView.layer.borderColor = customTintColor.cgColor
        containerView.layer.borderWidth = 0
        
        attachPhotoButton.accessibilityLabel = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        
        if let image = image {
            
            containerView.layer.borderWidth = 1
            attachedPhotoImageView.image = image
            attachPhotoButton.accessibilityLabel = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        }
    }
    
    func openDocumentViewer(deleteAction: @escaping (() -> Void)) {
        guard let parent = parent else { return }
        guard pickedImagePath != nil || attachedPhotoImageView.image != nil else { return }
        
        let documentViewerView = DHLDocumentViewerView(frame: .zero)
        documentViewerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.window?.addSubview(documentViewerView)
        
        if let parent = self.parent?.view {
            
            NSLayoutConstraint.activate([
                documentViewerView.topAnchor.constraint(equalTo: parent.topAnchor),
                documentViewerView.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
                documentViewerView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                documentViewerView.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
            ])
        }
        
        let data = try? Data(contentsOf: pickedImagePath ?? URL(fileURLWithPath: ""))
        
        documentViewerView.setUp(
            parent: parent,
            document: data,
            image: attachedPhotoImageView.image,
            showDelete: self.showDelete,
            showDownloadButton: false,
            deleteAction: {

                let fourButtonsModal = DHLFourButtonsModal(frame: .zero)
                fourButtonsModal.translatesAutoresizingMaskIntoConstraints = false
                
                self.window?.addSubview(fourButtonsModal)
                
                if let parent = self.parent?.view {
                    
                    NSLayoutConstraint.activate([
                        fourButtonsModal.topAnchor.constraint(equalTo: parent.topAnchor),
                        fourButtonsModal.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
                        fourButtonsModal.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                        fourButtonsModal.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
                    ])
                }
                
                fourButtonsModal.setUp(
                    title: NSLocalizedString("delete_photo_title", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
                    subtitle: NSLocalizedString("delete_photo_description", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
                    first: NSLocalizedString("delete", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
                    firstAction: {
                        documentViewerView.removeFromSuperview()
                        fourButtonsModal.removeFromSuperview()
                        deleteAction()
                    },
                    second: NSLocalizedString("cancel", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
                    secondAction: {
                        fourButtonsModal.removeFromSuperview()
                    },
                    secondButtonReserveColor: true
                )
            },
            cancelAction: {
                documentViewerView.removeFromSuperview()
            }
        )
    }

    // MARK: IBActions
    @IBAction func attachPhotoButtonPressed(_ sender: Any) {
        
        guard attachedPhotoImageView.image == nil else {
            openDocumentViewer(
                deleteAction: {
                    self.pickedImagePath = nil
                    self.attachedPhotoImageView.image = nil
                    self.containerView.layer.borderWidth = 0
                    self.attachPhotoButton.accessibilityLabel = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
            })
            return
        }
        
        let fourButtonsModal = DHLFourButtonsModal(frame: .zero)
        fourButtonsModal.translatesAutoresizingMaskIntoConstraints = false
        
        self.window?.addSubview(fourButtonsModal)
        
        if let parent = self.parent?.view {
            
            NSLayoutConstraint.activate([
                fourButtonsModal.topAnchor.constraint(equalTo: parent.topAnchor),
                fourButtonsModal.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
                fourButtonsModal.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                fourButtonsModal.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
            ])
        }
        
        fourButtonsModal.setUp(
            title: NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
            subtitle: NSLocalizedString("attach_photo_camera_or_gallery", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
            first: NSLocalizedString("camera", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
            firstAction: {
                #if targetEnvironment(simulator)
                self.imagePicker(source: .photoLibrary)
                #else
                self.imagePicker(source: .camera)
                #endif
                fourButtonsModal.removeFromSuperview()
            },
            second: NSLocalizedString("gallery", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
            secondAction: {
                self.imagePicker(source: .photoLibrary)
                fourButtonsModal.removeFromSuperview()
            },
            third: NSLocalizedString("cancel", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""),
            thirdAction: {
                fourButtonsModal.removeFromSuperview()
            },
            thirdButtonReserveColor: true
        )
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension DHLUploadPhotoView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if let pickedImagePath = info[.imageURL] as? URL {

                self.pickedImagePath = pickedImagePath
                attachedPhotoImageView.image = pickedImage
                attachPhotoButton.accessibilityLabel = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
                
                self.containerView.layer.borderWidth = 1

            } else if let documentsDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
               
                do {
                    try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    let imageUrl = documentsDirectory.appendingPathComponent("documento.jpg")
                    
                    try pickedImage.jpegData(compressionQuality: 1.0)?.write(to: imageUrl)
                    
                    self.pickedImagePath = imageUrl
                    attachedPhotoImageView.image = pickedImage
                    
                    self.containerView.layer.borderWidth = 1
                    attachPhotoButton.accessibilityLabel = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
                    
                } catch {
                    print("Error al guardar la imagen: \(error.localizedDescription)")
                }
            }
        }

        self.parent?.dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePicker(source: UIImagePickerController.SourceType) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source

        if source == .photoLibrary {
            // imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            imagePicker.mediaTypes = [UTType.image.identifier]
            
        } else if source == .camera {
            imagePicker.mediaTypes = [UTType.image.identifier]
        }

        self.parent?.present(imagePicker, animated: true, completion: nil)
    }
}
