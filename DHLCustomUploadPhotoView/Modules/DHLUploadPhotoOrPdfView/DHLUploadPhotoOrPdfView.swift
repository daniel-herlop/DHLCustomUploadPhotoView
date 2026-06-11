//
//  DHLUploadPhotoOrPdfView.swift
//  DHLCustomUploadPhotoView
//
//  Created by Daniel Hernandez on 18/6/25.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

class DHLUploadPhotoOrPdfView: UIView {
    
    @IBOutlet weak var addNewDocumentLabel: UILabel!
    
    @IBOutlet weak var attachPhoto: DHLCustomDashedView!
    @IBOutlet weak var attachPhotoLabel: UILabel!
    @IBOutlet weak var attachedPhotoImageView: UIImageView!
    @IBOutlet weak var attachPhotoButton: UIButton!
    @IBOutlet weak var photoViewZeroWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var attachPdf: DHLCustomDashedView!
    @IBOutlet weak var attachPdfLabel: UILabel!
    @IBOutlet weak var attachedPdfImageView: UIImageView!
    @IBOutlet weak var attachPdfButton: UIButton!
    @IBOutlet weak var pdfViewZeroWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var spaceBetweenViewsConstraint: NSLayoutConstraint!
    
    private var documentPickedAction: ((URL, Data?) -> Void)?
    private var documentDeletedAction: (() -> Void)?
    
    var data: Data?
    
    var pickedImagePath: URL?
    var pickedPdfPath: URL?
    var parent: UIViewController?
    var showDelete: Bool = true
    private var customTintColor: UIColor = .blue

    override init(frame: CGRect) {

        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {

        backgroundColor = .clear

        if let xibView = Bundle.main.loadNibNamed("DHLUploadPhotoOrPdfView", owner: self, options: nil)?.first as? UIView {

            xibView.frame = self.bounds
            xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(xibView)

            commonInit()
        }
    }

    override func awakeFromNib() {

        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {
        
        setUpAccessiblity()
        setUpViews()
    }
    
    func setUpAccessiblity() {
        
        attachPhotoLabel.isAccessibilityElement = false
        attachPdfLabel.isAccessibilityElement = false
        attachPdfButton.accessibilityLabel = NSLocalizedString("attach_pdf", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        attachPhotoButton.accessibilityLabel = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        addNewDocumentLabel.text = NSLocalizedString("add_new_document", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
    }
    
    func setUpViews() {
        
        
        attachPhoto.layer.cornerRadius = 8
        attachPdf.layer.cornerRadius = 8

        attachPdf.cornerRadius = 8
        attachPdf.dashWidth = 1.5
        attachPdf.dashLength = 6
        attachPdf.betweenDashesSpace = 3
        
        attachPhoto.cornerRadius = 8
        attachPhoto.dashWidth = 1.5
        attachPhoto.dashLength = 6
        attachPhoto.betweenDashesSpace = 3
        
        attachPhotoLabel.text = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        attachPdfLabel.text = NSLocalizedString("attach_pdf", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
    }

    // data para cargar un archivo, ya sea pdf o png/jpg
    func setUp(parent: UIViewController?, font: UIFont = .systemFont(ofSize: 14), customTintColor: UIColor = .blue, showDelete: Bool = true, titleText: String? = nil, mandatory: Bool = false, data: Data? = nil, documentPickedAction: @escaping ((URL, Data?) -> Void) = { document, data in }, documentDeletedAction: @escaping (() -> Void) = { }) {
        self.parent = parent
        self.documentPickedAction = documentPickedAction
        self.documentDeletedAction = documentDeletedAction
        self.data = data
        self.showDelete = showDelete
        self.customTintColor = customTintColor
        
        addNewDocumentLabel.font = font
        attachPhotoLabel.font = font
        attachPdfLabel.font = font
        
        attachPhoto.dashColor = customTintColor
        attachPdf.dashColor = customTintColor
        
        var labelText = NSLocalizedString("add_new_document", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        
        if let titleText = titleText {
            labelText = titleText
        }
        
        if mandatory {
            labelText.append(" *")
        }

        addNewDocumentLabel.attributedText = labelText.redAsterisks()
        
        addNewDocumentLabel.accessibilityLabel = addNewDocumentLabel.text?.replacingLastOccurrence(of: "*", with: "")
        
        if mandatory {
            addNewDocumentLabel.accessibilityLabel?.append(NSLocalizedString("mandatory", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: ""))
        }
        
        pickedImagePath = nil
        attachedPhotoImageView.image = nil
        
        pickedPdfPath = nil
        attachedPdfImageView.image = nil
        
        hideAnotherView()
        
        if let data = data {
            
            pdfViewZeroWidthConstraint.priority = UILayoutPriority(1000)
            attachPdf.isHidden = true
            spaceBetweenViewsConstraint.constant = 0
            
            attachPhoto.layer.borderColor = customTintColor.cgColor
            attachPhoto.layer.borderWidth = 1
            
            attachPhotoButton.accessibilityLabel = NSLocalizedString("see_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
            attachPdfButton.accessibilityLabel = NSLocalizedString("see_pdf", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
            
            if data.isImage(), let image = UIImage(data: data) {
                attachedPhotoImageView.image = image
                
            } else if let image = data.pdfDataToUIImage() {
                attachedPhotoImageView.image = image
                
            } else {
                attachedPhotoImageView.image = UIImage(named: "no_image", in: Bundle(for: DHLUploadPhotoOrPdfView.self), compatibleWith: nil) // igual se podria poner un wrong_image en vez del no_image, aunque en principio no deberia pasar nunca que la imagen no sea correcta
            }
        }
    }
    
    func hideAnotherView() {
        pdfViewZeroWidthConstraint.priority = UILayoutPriority(100)
        attachPdf.isHidden = false
        photoViewZeroWidthConstraint.priority = UILayoutPriority(100)
        attachPhoto.isHidden = false
        
        attachPdfButton.accessibilityLabel = NSLocalizedString("attach_pdf", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        attachPhotoButton.accessibilityLabel = NSLocalizedString("attach_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        
        if pickedImagePath != nil {
            pdfViewZeroWidthConstraint.priority = UILayoutPriority(1000)
            attachPdf.isHidden = true
            spaceBetweenViewsConstraint.constant = 0
            
            attachPhotoButton.accessibilityLabel = NSLocalizedString("see_photo", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
            
        } else if pickedPdfPath != nil {
            photoViewZeroWidthConstraint.priority = UILayoutPriority(1000)
            attachPhoto.isHidden = true
            spaceBetweenViewsConstraint.constant = 0
            
            attachPdfButton.accessibilityLabel = NSLocalizedString("see_pdf", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
            
        } else {
            
            spaceBetweenViewsConstraint.constant = 16
            attachPdf.layer.borderWidth = 0
            attachPhoto.layer.borderWidth = 0
        }
        
        // UIAccessibility.post(notification: .layoutChanged, argument: addNewDocumentLabel)
    }
    
    func openDocumentViewer(data: Data?, deleteAction: @escaping (() -> Void)) {
        guard let data = data else { return }
        guard let parent = parent else { return }
        
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
        
        documentViewerView.setUp(
            parent: parent,
            document: data,
            showDelete: showDelete,
            showDownloadButton: false,
            deleteAction: {
                /*
                parent.showTwoButtons(
                    R.string.strings.delete_photo_title(),
                    description: R.string.strings.delete_photo_description(),
                    image: R.image.ic_warning(),
                    first: R.string.strings.delete(),
                    firstAction: {
                        
                        documentViewerView.removeFromSuperview()
                        deleteAction()
                    },
                    second: R.string.strings.cancel(),
                    secondAction: {
                    }
                )
                */
            },
            cancelAction: {
                documentViewerView.removeFromSuperview()
            }
        )
    }
    
    func imagePicked(imageUrl: URL, pickedImage: UIImage) {
        self.pickedImagePath = imageUrl
        
        attachedPhotoImageView.image = pickedImage
        hideAnotherView()
        
        attachPhoto.layer.borderColor = customTintColor.cgColor
        attachPhoto.layer.borderWidth = 1
        
        self.data = try? Data(contentsOf: imageUrl)
        
        self.documentPickedAction?(imageUrl, self.data)
        UIAccessibility.post(notification: .layoutChanged, argument: self.addNewDocumentLabel)
    }

    // MARK: IBActions
    @IBAction func attachPhotoButtonPressed(_ sender: Any) {
        guard attachedPhotoImageView.image == nil else {
            
            let data = self.data ?? (try? Data(contentsOf: pickedImagePath!))
            
            openDocumentViewer(
                data: data,
                deleteAction: {
                    self.pickedImagePath = nil
                    self.attachedPhotoImageView.image = nil
                    self.data = nil
                    
                    self.hideAnotherView()
                    self.documentDeletedAction?()
                    UIAccessibility.post(notification: .layoutChanged, argument: self.addNewDocumentLabel)
            })
            return
        }
        
        guard let parent = parent else { return }
        /*
        parent.showThreeButtons(
            R.string.strings.attach_photo(),
            description: R.string.strings.attach_photo_camera_or_gallery(),
            image: R.image.dialog_default(),
            first: R.string.strings.camera(),
            firstAction: {

    #if targetEnvironment(simulator)
                self.imagePicker(source: .photoLibrary)
    #else
                self.imagePicker(source: .camera)
    #endif
            },
            second: R.string.strings.gallery(),
            secondAction: {

                self.imagePicker(source: .photoLibrary)
            },
            third: R.string.strings.cancel(),
            thirdAction: {
            }
        )
         */
    }
    
    @IBAction func attachPdfButtonPressed(_ sender: Any) {
        guard attachedPdfImageView.image == nil else {
            
            let _ = pickedPdfPath?.startAccessingSecurityScopedResource()
            let data = self.data ?? (try? Data(contentsOf: pickedPdfPath!))
            let _ = pickedPdfPath?.stopAccessingSecurityScopedResource()
            
            openDocumentViewer(
                data: data,
                deleteAction: {
                    self.pickedPdfPath = nil
                    self.attachedPdfImageView.image = nil
                    self.data = nil
                    
                    self.hideAnotherView()
                    self.documentDeletedAction?()
                    UIAccessibility.post(notification: .layoutChanged, argument: self.addNewDocumentLabel)
            })
            return
        }
        
        let pdfs = UTType.types(tag: "pdf", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        let doxy = UIDocumentPickerViewController(forOpeningContentTypes: pdfs)
        
        doxy.delegate = self
        self.parent?.present(doxy, animated: true, completion: nil)
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension DHLUploadPhotoOrPdfView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if let pickedImagePath = info[.imageURL] as? URL {

                self.imagePicked(imageUrl: pickedImagePath, pickedImage: pickedImage)

            } else if let documentsDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                do {
                    try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    let imageUrl = documentsDirectory.appendingPathComponent("documento.jpg")
                    
                    try pickedImage.jpegData(compressionQuality: 1.0)?.write(to: imageUrl, options: .atomic)
                    
                    self.imagePicked(imageUrl: imageUrl, pickedImage: pickedImage)

                } catch {
                    print("Error al guardar la imagen: \(error.localizedDescription)")
                }
            }
        }

        self.parent?.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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

//********************************************
// MARK: - UIDocumentPickerController Delegate
//********************************************

extension DHLUploadPhotoOrPdfView: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
              return
        }
        
        self.pickedPdfPath = url
        self.attachedPdfImageView.image = nil
        self.hideAnotherView()
        
        let _ = url.startAccessingSecurityScopedResource()
        data = try? Data(contentsOf: url)
        
        self.documentPickedAction?(url, data)

        self.attachedPdfImageView.image = url.getImagefromURL()
        
        attachPdf.layer.borderColor = customTintColor.cgColor
        attachPdf.layer.borderWidth = 1
        
        let _ = url.stopAccessingSecurityScopedResource()
        UIAccessibility.post(notification: .layoutChanged, argument: self.addNewDocumentLabel)
    }
}
