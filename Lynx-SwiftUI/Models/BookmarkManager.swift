//
//  BookmarkManager.swift
//  Lynx
//
//  Created by Matthew Ernst on 6/20/23.
//

import Foundation
import OSLog

class BookmarkManager {
    static let shared = BookmarkManager()
    
    private(set) var bookmark: (id: String, url: URL)?
    
    private var appSandboxDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveBookmark(for url: URL) {
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
            let bookmarkData = try url.bookmarkData(
                options: .minimalBookmark,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            // Save the bookmark into a file (the name of the file is the UUID)
            try bookmarkData.write(to: appSandboxDirectory.appendingPathComponent(id))
            
            // Add the URL and UUID to the urls
            bookmark = (id, url)
            Logger.bookmarkManager.info("Successfully Saved Bookmarks")
        }
        catch {
            // Handle the error here.
            Logger.bookmarkManager.error("Error creating the bookmark: \(error)")
        }
    }
    
    func loadAllBookmarks() {
        // Get all the bookmark files
        let files = try? FileManager.default.contentsOfDirectory(at: appSandboxDirectory, includingPropertiesForKeys: nil)
        // Map over the bookmark files
        let bookmarks = files?.compactMap { file in
            do {
                let bookmarkData = try Data(contentsOf: file)
                var isStale = false
                // Get the URL from each bookmark
                let url = try URL(
                    resolvingBookmarkData: bookmarkData,
                    bookmarkDataIsStale: &isStale
                )
                
                guard !isStale else {
                    // Handle stale data here.
                    return nil
                }
                
                Logger.bookmarkManager.info("Successfully Saved Bookmarks")
                // Return URL
                return (file.lastPathComponent, url)
            }
            catch let error {
                // Handle the error here.
                Logger.bookmarkManager.error("Error loading bookmarks: \(error)")
                return nil
            }
        } ?? Array<(id: String, url: URL)>()
        
        self.bookmark = bookmarks.first
    }
    
    func removeAllBookmarks() {
        let fileManager = FileManager.default
        
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: appSandboxDirectory, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in directoryContents {
                try? fileManager.removeItem(at: fileURL)
            }
            Logger.bookmarkManager.info("Successfully Removed All Bookmarks")
        } catch {
            Logger.bookmarkManager.error("Error removing bookmarks: \(error)")
        }
    }
}
