//
//  DHLDocumentViewerView.swift
//  DHLCustomUploadPhotoView
//
//  Created by Daniel Hernandez on 24/4/25.
//

import UIKit
import WebKit

public class DHLDocumentViewerView: UIView, UIScrollViewDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteImageView: UIImageView!
    @IBOutlet weak var deleteViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var cancelImageView: UIImageView!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var webView: WKWebView!
    
    private var deleteAction: (() -> Void)?
    private var cancelAction: (() -> Void)?
    
    private var parent: UIViewController?
    private var url: String?
    private var document: Data?
    private var image: UIImage?
    private var downloadFileName: String?
    
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
        
        let bundle = Bundle(for: DHLDocumentViewerView.self)
        
        if let xibView = bundle.loadNibNamed("DHLDocumentViewerView", owner: self, options: nil)?.first as? UIView {
            
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
        
        cancelButton.accessibilityLabel = NSLocalizedString("go_back", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        deleteButton.accessibilityLabel = NSLocalizedString("delete", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        downloadButton.accessibilityLabel = NSLocalizedString("download", tableName: "Strings", bundle: Bundle(for: DHLUploadPhotoView.self), comment: "")
        // photoImageView.accessibilityLabel = R.string.accessibility.photo()
        photoImageView.isAccessibilityElement = true
        
        containerView.layer.cornerRadius = 8
        
        deleteView.layer.cornerRadius = deleteView.frame.height / 2
        deleteView.layer.borderColor = UIColor.red.cgColor
        deleteView.layer.borderWidth = 1.5
        deleteView.backgroundColor = .white
        
        downloadView.layer.cornerRadius = deleteView.frame.height / 2
        
        cancelView.layer.cornerRadius = cancelView.frame.height / 2
        cancelImageView.image = cancelImageView.image
        
        titleLabel.accessibilityTraits = .header
    }
    
    // document para cargar un Data, ya sea una imagen o un pdf
    // image para cargar una UIImage directamente
    // url para cargar una url del servicio
    public func setUp(parent: UIViewController?, title: String? = nil, titleFont: UIFont = .systemFont(ofSize: 18, weight: .bold), document: Data? = nil, image: UIImage? = nil, url: String? = nil, showDelete: Bool, showDownloadButton: Bool, downloadFileName: String? = nil, allowZoom: Bool = true, deleteAction: @escaping (() -> Void), cancelAction: @escaping (() -> Void)) {
        self.cancelAction = cancelAction
        self.deleteAction = deleteAction
        self.url = url
        self.parent = parent
        self.document = document
        self.image = image
        self.downloadFileName = downloadFileName
        
        titleLabel.font = titleFont
        
        if showDelete {
            deleteView.isHidden = false
            deleteViewWidthConstraint.constant = 42
        } else {
            deleteView.isHidden = true
            deleteViewWidthConstraint.constant = 0
        }
        
        if showDownloadButton {
            downloadView.isHidden = false
        } else {
            downloadView.isHidden = true
        }
        
        if let document = document {
            
            if document.isImage(), let image = UIImage(data: document) {
                photoImageView.image = image
                
            } else {
                
                webView.isHidden = false
                photoImageView.isHidden = true
                webView.loadPDFData(document)
            }
    
        } else if let image = image {
            webView.isHidden = true
            photoImageView.isHidden = false
            photoImageView.image = image
            
        } else if let url = url {
            // photoImageView.set(url)
            
            if let url = URL(string: url) {
                webView.isHidden = false
                photoImageView.isHidden = true
                webView.load(URLRequest(url: url))
            }
        }
        
        if let title = title, !title.isEmpty {
            titleLabel.text = title
            
        } else {
            titleLabel.text = ""
            titleLabelTopConstraint.constant = 0
            titleLabelBottomConstraint.constant = 0
        }
        
        if allowZoom {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 4.0
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    
    var docController: UIDocumentInteractionController?
    @IBAction func downloadButtonPressed(_ sender: Any) {
        if let urlString = url, let url = URL(string: urlString) {
            
            // self.parent?.showLoading(show: true)
            
            FileManagerHelper.downloadFile(fileName: downloadFileName ?? UUID().uuidString, url) { [weak self] (result) in
                guard let self = self else { return }
                
                // self.parent?.showLoading(show: false)

                switch result {
                case .success(let path):
                    showDocumentController(path: path)

                case .failure(let error):
                    print("TODO error")
                    /*
                    self.parent?.showOK(
                        R.string.strings.ups(),
                        description: error.localizedDescription,
                        image: R.image.ic_warning()!.tinted(withColor: R.color.blue_app()!)
                    )
                    */
                }
            }
            
        } else if let document = document {
            showDocumentController(data: document)
            
        } else if let image = image {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                showDocumentController(data: imageData)
            }
        }
    }
    
    func showDocumentController(path: String) {
        let fileUrl = URL(fileURLWithPath: path)
        
        self.docController = UIDocumentInteractionController(url: fileUrl)
        if let url = URL(string: "itms-books:"), UIApplication.shared.canOpenURL(url) {

            self.docController?.presentOpenInMenu(from: .zero, in: self.parent!.view!, animated: true)
        }
    }
    
    func showDocumentController(data: Data) {
        
        let fileExtension = data.isImage() ? "jpg" : "pdf"
        
           let tempURL = FileManager.default.temporaryDirectory
               .appendingPathComponent(downloadFileName ?? UUID().uuidString)
               .appendingPathExtension(fileExtension)
        print(tempURL)
           do {
               try data.write(to: tempURL, options: .atomic)

               self.docController = UIDocumentInteractionController(url: tempURL)

               self.docController?.presentOpenInMenu(
                   from: .zero,
                   in: self.parent!.view!,
                   animated: true
               )

           } catch {
               print("Error escribiendo archivo temporal: \(error)")
           }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        cancelAction?()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        deleteAction?()
    }
}
