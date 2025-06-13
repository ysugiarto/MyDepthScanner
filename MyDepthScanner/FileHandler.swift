//
//  FileHandler.swift
//  MyDepthScanner
//
//  Created by Yohanes Sugiarto on 11/08/24.
//

import Foundation
import Metal
import SceneKit

final class FileHandler {
    static func writeTxt(fileName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let file = documentsDirectory.appendingPathComponent("\(fileName)_\(Date().description(with: .current)).txt", isDirectory: false)
        FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        
        var content = "Test saving file"
        do {
            try content.write(to: file, atomically: true, encoding: .ascii)
        } catch {
            print(error.localizedDescription)
        }
        
        return file
    }
    
    static func writePly(fileName: String,
                         pointCloudBuffer: inout MTLBuffer,
                         pointCount: Int) throws -> URL {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let plyFile = documentsDirectory.appendingPathComponent(
            "\(fileName)_\(Date().description(with: .current)).ply", isDirectory: false)
        FileManager.default.createFile(atPath: plyFile.path, contents: nil, attributes: nil)
        
        // Access point cloud data from the buffer
        let pointCloudDataPointer = pointCloudBuffer.contents().bindMemory(to: PointData.self, capacity: pointCount)
            
        // Load buffer data into an array and filter
        let pointCloudArray = Array(UnsafeBufferPointer(start: pointCloudDataPointer, count: pointCount))
        let filteredPoints = pointCloudArray.filter { $0.depth >= 0 && $0.depth <= 400 }
        let filteredPointCount = filteredPoints.count
        
        //let testPoint = filteredPoints.first!
        //let testTxt = "\(testPoint.position.x) \(testPoint.position.y) \(testPoint.position.z) \(testPoint.depth)"
        //print(testTxt)
        
        /*var headersString = ""
        let headers = [
            "ply",
            "comment Created by Sugie (2024)",
            "format ascii 1.0",
            "element vertex \(filteredPointCount)",
            "property float x",
            "property float y",
            "property float z",
            "property float depth",
            "end_header"]
        
        for header in headers { headersString += header + "\r\n" }
        try headersString.write(to: plyFile, atomically: true, encoding: .ascii)
        
        // Append point data
        var plyContent = ""
        for point in filteredPoints {
            let line = "\n\(point.position.x) \(point.position.y) \(point.position.z) \(point.depth)"
            plyContent += line
        }
        /*for i in 0..<pointCount {
            let point = pointCloudData[i]
            let line = "\n\(point.position.x) \(point.position.y) \(point.position.z) \(point.depth)"
            plyContent += line
        }*/
        
        
        
        let fileHandle = try FileHandle(forWritingTo: plyFile)
        fileHandle.seekToEndOfFile()
        fileHandle.write(plyContent.data(using: .ascii)!)
        fileHandle.closeFile()
        
        return plyFile*/
        // Build the PLY content
        var plyContent = """
        ply
        comment Created by Sugie (2024)
        format ascii 1.0
        element vertex \(filteredPointCount)
        property float x
        property float y
        property float z
        property float depth
        end_header

        """
        
        // Append each point to the PLY content
        for point in filteredPoints {
            plyContent += "\(point.position.x) \(point.position.y) \(point.position.z) \(point.depth)\n"
        }
        
        // Write the full content to the file in a single operation
        try plyContent.write(to: plyFile, atomically: true, encoding: .ascii)
        
        return plyFile
        
        /*let faceCount = filteredPointCount / 3  // Assuming each 3 points form a triangle
        
        // Prepare PLY header with vertex and face definitions
        var headersString = ""
        let headers = [
            "ply",
            "comment Created by Sugie (2024)",
            "format ascii 1.0",
            "element vertex \(filteredPointCount)",
            "property float x",
            "property float y",
            "property float z",
            "property float depth",
            "element face \(faceCount)",
            "property list uchar int vertex_indices",
            "end_header"
        ]
        for header in headers { headersString += header + "\r\n" }
        try headersString.write(to: plyFile, atomically: true, encoding: .ascii)
        
        // Write vertex data
        var plyContent = ""
        for point in filteredPoints {
            let line = "\(point.position.x) \(point.position.y) \(point.position.z) \(point.depth)\n"
            plyContent += line
        }
        
        // Write face data (each 3 consecutive vertices form a face)
        for i in stride(from: 0, to: filteredPointCount - 2, by: 3) {
            let faceLine = "3 \(i) \(i + 1) \(i + 2)\n"
            plyContent += faceLine
        }
        
        // Save the content to the file
        let fileHandle = try FileHandle(forWritingTo: plyFile)
        fileHandle.seekToEndOfFile()
        fileHandle.write(plyContent.data(using: .ascii)!)
        fileHandle.closeFile()
        
        return plyFile
         */
    }
    
    // Function to write the PLY file with triangulated faces
    static func writePlyWithDelaunay(fileName: String, pointCloudBuffer: inout MTLBuffer, pointCount: Int) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let plyFile = documentsDirectory.appendingPathComponent("\(fileName)_\(Date().description(with: .current)).ply", isDirectory: false)
        FileManager.default.createFile(atPath: plyFile.path, contents: nil, attributes: nil)
        
        // Access point cloud data
        let pointCloudData = pointCloudBuffer.contents().bindMemory(to: PointData.self, capacity: pointCount)
        let filteredPoints = UnsafeBufferPointer(start: pointCloudData, count: pointCount)
            .filter { $0.depth >= 0 && $0.depth <= 400 }
        
        // Perform Delaunay triangulation on projected 2D points
        var vertices3D = [SIMD3<Float>]()
        var vertices2D = [CGPoint]()
        
        for point in filteredPoints {
            vertices3D.append(point.position)
            vertices2D.append(CGPoint(x: CGFloat(point.position.x), y: CGFloat(point.position.z)))
        }
        
        // Use SceneKit to generate a 2D triangulation (approximate)
        let scene = SCNScene()
        let geometrySource = SCNGeometrySource(vertices: vertices2D.map { SCNVector3($0.x, 0, $0.y) })
        let delaunay2D = SCNGeometry(sources: [geometrySource], elements: nil)
        scene.rootNode.geometry = delaunay2D
        
        let elements = delaunay2D.elements
        var faces = [(Int, Int, Int)]()
        
        // Convert SceneKit triangle indices back to original points
        for element in elements {
            let indexData = element.data
            let indices = indexData.withUnsafeBytes { buffer -> [Int32] in
                let pointer = buffer.bindMemory(to: Int32.self)
                return Array(pointer)
            }
            
            for i in stride(from: 0, to: indices.count, by: 3) {
                faces.append((Int(indices[i]), Int(indices[i+1]), Int(indices[i+2])))
            }
        }
        
        // Prepare header for PLY
        var headersString = ""
        let headers = [
            "ply",
            "comment Created by Sugie (2024)",
            "format ascii 1.0",
            "element vertex \(vertices3D.count)",
            "property float x",
            "property float y",
            "property float z",
            "property float depth",
            "element face \(faces.count)",
            "property list uchar int vertex_indices",
            "end_header"
        ]
        for header in headers { headersString += header + "\r\n" }
        try headersString.write(to: plyFile, atomically: true, encoding: .ascii)
        
        // Write vertex data
        var plyContent = ""
        for point in filteredPoints {
            let line = "\(point.position.x) \(point.position.y) \(point.position.z) \(point.depth)\n"
            plyContent += line
        }
        
        // Write face data based on triangulation
        for face in faces {
            let faceLine = "3 \(face.0) \(face.1) \(face.2)\n"
            plyContent += faceLine
        }
        
        // Save the content to the file
        let fileHandle = try FileHandle(forWritingTo: plyFile)
        fileHandle.seekToEndOfFile()
        fileHandle.write(plyContent.data(using: .ascii)!)
        fileHandle.closeFile()
        
        return plyFile
    }
    
}
