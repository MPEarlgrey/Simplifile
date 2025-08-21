import Foundation

let fileManager = FileManager.default
let downloads = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")

let typeFolders: [String: [String]] = [
    "Documents": ["pdf", "doc", "docx", "txt", "odt", "xlsx", "csv"],
    "Images": ["jpg", "jpeg", "png", "gif", "bmp", "webp", "svg", "heic", "avif"],
    "Videos": ["mp4", "mov", "avi", "mkv", "webm"],
    "Audio": ["mp3", "wav", "m4a", "flac"],
    "Archives": ["zip", "rar", "7z", "tar", "gz"],
    "Programs": ["dmg", "pkg", "exe", "msi"],
    "Fonts": ["ttf", "otf", "woff", "woff2"],
    "3D Models": ["stl", "obj", "blend", "3mf", "glb", "gcode"],
    "Presentations": ["ppt", "pptx", "key", "odp"],
    "Code": ["py", "js", "html", "css", "swift", "java", "c", "cpp", "sh", "json", "xml"],
    "Maps": ["map"],
    "Torrents": ["torrent"]
]

do {
    let contents = try fileManager.contentsOfDirectory(at: downloads, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
    
    for file in contents {
        guard !file.hasDirectoryPath else { continue }
        let ext = file.pathExtension.lowercased()
        let base = file.lastPathComponent
        
        let category = typeFolders.first(where: { $0.value.contains(ext) })?.key ?? "Other"
        let destinationFolder = downloads.appendingPathComponent(category)
        
        if !fileManager.fileExists(atPath: destinationFolder.path) {
            try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
        }
        
        let destination = destinationFolder.appendingPathComponent(base)
        
        if !fileManager.fileExists(atPath: destination.path) {
            try fileManager.moveItem(at: file, to: destination)
            print("✓ Moved: \(base) → \(category)")
        } else {
            print("✗ Skipped (already exists): \(base)")
        }
    }

    print("Sorting complete.")

} catch {
    print("Error: \(error.localizedDescription)")
}
