//
//  BookmarkManager.swift
//  Lynx
//
//  Created by Matthew Ernst on 6/20/23.
//

import Foundation
import OSLog

class BookmarkManager {
    private(set) var bookmark: (id: String, url: URL)?
    
    private static func getAppSandboxDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public func saveBookmark(for url: URL) {
        do {
            // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                return
            }
            
            if bookmark?.url == url { return }
            
            // Make sure you release the security-scoped resource when you finish.
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Generate a UUID
            let id = UUID().uuidString
            
            // Convert URL to bookmark
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            // Save the bookmark into a file (the name of the file is the UUID)
            try bookmarkData.write(to: BookmarkManager.getAppSandboxDirectory().appendingPathComponent(id))
            
            // Add the URL and UUID to the urls
            bookmark = (id, url)
        }
        catch {
            // Handle the error here.
            Logger.bookmarkManager.debug("Error creating the bookmark: \(error)")
        }
    }
    
    public func loadAllBookmarks() {
        // Get all the bookmark files
        let files = try? FileManager.default.contentsOfDirectory(at: BookmarkManager.getAppSandboxDirectory(), includingPropertiesForKeys: nil)
        // Map over the bookmark files
        let bookmarks = files?.compactMap { file in
            do {
                let bookmarkData = try Data(contentsOf: file)
                var isStale = false
                // Get the URL from each bookmark
                let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                
                guard !isStale else {
                    // Handle stale data here.
                    return nil
                }
                
                // Return URL
                return (file.lastPathComponent, url)
            }
            catch let error {
                // Handle the error here.
                print(error)
                return nil
            }
        } ?? Array<(id: String, url: URL)>()
        
        self.bookmark = bookmarks.first
    }
    
    static func removeAllBookmarks() {
        let fileManager = FileManager.default
        let appSandboxDirectory = BookmarkManager.getAppSandboxDirectory()
        
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: appSandboxDirectory, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in directoryContents {
                try? fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error removing bookmarks: \(error)")
        }
    }
    
}
