import Foundation 

  

let fileManager = FileManager.default 

  

let targetPath: String 

if CommandLine.arguments.count > 1 { 

    targetPath = CommandLine.arguments[1] 

} else { 

    print("Enter folder path to organize (default: ~/Downloads): ", terminator: "") 

    let input = readLine()?.trimmingCharacters(in: .whitespaces) ?? "" 

    targetPath = input.isEmpty 

        ? fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").path 

        : input 

} 

  

let expandedPath = (targetPath as NSString).expandingTildeInPath 

let targetURL = URL(fileURLWithPath: expandedPath) 

  

var isDirectory: ObjCBool = false 

guard fileManager.fileExists(atPath: expandedPath, isDirectory: &isDirectory), isDirectory.boolValue else { 

    print("✗ Not a valid directory: \(expandedPath)") 

    exit(1) 

} 

  

let typeFolders: [String: [String]] = [ 

    "Documents":     ["pdf", "doc", "docx", "txt", "odt", "xlsx", "csv"], 

    "Images":        ["jpg", "jpeg", "png", "gif", "bmp", "webp", "svg", "heic", "avif"], 

    "Videos":        ["mp4", "mov", "avi", "mkv", "webm"], 

    "Audio":         ["mp3", "wav", "m4a", "flac"], 

    "Archives":      ["zip", "rar", "7z", "tar", "gz"], 

    "Programs":      ["dmg", "pkg", "exe", "msi"], 

    "Fonts":         ["ttf", "otf", "woff", "woff2"], 

    "3D Models":     ["stl", "obj", "blend", "3mf", "glb", "gcode"], 

    "Presentations": ["ppt", "pptx", "key", "odp"], 

    "Code":          ["py", "js", "html", "css", "swift", "java", "c", "cpp", "sh", "json", "xml", "map"], 

    "Torrents":      ["torrent"] 

] 

  

var extensionMap: [String: String] = [:] 

for (category, exts) in typeFolders { 

    for ext in exts { 

        extensionMap[ext] = category 

    } 

} 

  

print("Organizing: \(expandedPath)\n") 

  

do { 

    let contents = try fileManager.contentsOfDirectory( 

        at: targetURL, 

        includingPropertiesForKeys: nil, 

        options: [.skipsHiddenFiles] 

    ) 

  

    var moved = 0, failed = 0 

  

    for file in contents { 

        guard !file.hasDirectoryPath else { continue } 

  

        let ext      = file.pathExtension.lowercased() 

        let baseName = file.deletingPathExtension().lastPathComponent 

        let fullName = file.lastPathComponent 

        let category = extensionMap[ext] ?? "Other" 

  

        let destinationFolder = targetURL.appendingPathComponent(category) 

  

        if !fileManager.fileExists(atPath: destinationFolder.path) { 

            do { 

                try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true) 

            } catch { 

                print("✗ Could not create folder '\(category)': \(error.localizedDescription)") 

                failed += 1 

                continue 

            } 

        } 

  

        var destination = destinationFolder.appendingPathComponent(fullName) 

        var counter = 1 

        while fileManager.fileExists(atPath: destination.path) { 

            let newName = ext.isEmpty 

                ? "\(baseName) (\(counter))" 

                : "\(baseName) (\(counter)).\(ext)" 

            destination = destinationFolder.appendingPathComponent(newName) 

            counter += 1 

        } 

  

        do { 

            try fileManager.moveItem(at: file, to: destination) 

            print("✓ Moved: \(fullName) → \(category)/\(destination.lastPathComponent)") 

            moved += 1 

        } catch { 

            print("✗ Failed: '\(fullName)': \(error.localizedDescription)") 

            failed += 1 

        } 

    } 

  

    print("\nDone — \(moved) moved, \(failed) failed.") 

} catch { 

    print("Error reading folder: \(error.localizedDescription)") 

    exit(1) 

} 
