# DHLCustomUploadPhotoView

Custom views to upload and view photos and PDFs.

![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![Platform](https://img.shields.io/badge/iOS-14%2B-blue)

## Preview
![Screenshot](docs/screenshot1.png)

![Screenshot](docs/screenshot2.png)

![Screenshot](docs/screenshot3.png)

![Screenshot](docs/screenshot4.png)

## Installation

### CocoaPods

```ruby
pod 'DHLCustomUploadPhotoView'
```

## Quick Start

### UIKit

```swift
let documentViewerView = DHLDocumentViewerView(frame: .zero)
documentViewerView.translatesAutoresizingMaskIntoConstraints = false

self.window?.addSubview(documentViewerView)

    
NSLayoutConstraint.activate([
    documentViewerView.topAnchor.constraint(equalTo: view.topAnchor),
    documentViewerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    documentViewerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    documentViewerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
])

documentViewerView.setUp(
    parent: self.parentViewController,
    title: self.especie?.getNombre(),
    document: data,
    showDelete: false,
    showDownloadButton: false,
    allowZoom: true,
    deleteAction: {},
    cancelAction: {
        documentViewerView.removeFromSuperview()
    }
)
```
