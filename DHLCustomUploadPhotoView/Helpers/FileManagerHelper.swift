//
//  FileManagerHelper.swift
//  DHLCustomUploadPhotoView
//
//  Created by Daniel Hernandez on 11/06/2026.
//

import Foundation
import Alamofire

class FileManagerHelper {
    // se descarga el archivo sin guardarlo en local
    public static func downloadFile(fileName: String, _ url: URL, completion: ((Result<String, Error>) -> Void)? = nil) {
        
        let destination: DownloadRequest.Destination = { _, _ in
            
            let documentsURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(fileName).pdf")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(url, to: destination).response { response in
            
            DispatchQueue.main.async {
                
                if response.error == nil, let path = response.fileURL?.path {
                    
                    completion?(Result.success(path))
                    
                } else if let error = response.error {
                    
                    completion?(Result.failure(error))
                }
            }
        }
    }
}
