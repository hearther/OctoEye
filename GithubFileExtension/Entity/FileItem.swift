//
//  FileItem.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import FileProvider
import UTIKit
import RealmSwift

class FileItem {
    private let entryObject : EntryObject
    private let parentItemIdentifier : NSFileProviderItemIdentifier

    init(entryObject : EntryObject, parentItemIdentifier : NSFileProviderItemIdentifier) {
        self.entryObject = entryObject
        self.parentItemIdentifier = parentItemIdentifier
    }

    func build() -> GithubObjectItem {
        let object = GithubObjectItem()
        object.itemIdentifier = itemIdentifier()
        object.parentItemIdentifier = parentItemIdentifier
        object.filename = filename()
        object.typeIdentifier = typeIdentifier()
        object.owner = entryObject.repository.owner.login
        object.repositoryName = entryObject.repository.name
        object.oid = entryObject.oid
        return object
    }

    private func itemIdentifier() -> NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier(
            [
                "gitobject",
                entryObject.repository.owner.login,
                entryObject.repository.name,
                entryObject.oid
            ].joined(separator: ".")
        )
    }

    private func filename() -> String {
        return entryObject.name
    }

    private func typeIdentifier() -> String {
        if entryObject.type == "blob" {
            if let uti = UTI(filenameExtension: (entryObject.name as NSString).pathExtension) {
                return uti.utiString
            } else {
                return "public.item"
            }
        } else {
            return "public.folder"
        }
    }

    class func parse(itemIdentifier: NSFileProviderItemIdentifier) -> (String, String, String)? {
        let xs = itemIdentifier.rawValue.components(separatedBy: ".")

        if xs.count == 4 && xs[0] == "gitobject" {
            return (xs[1], xs[2], xs[3])
        } else {
            return nil
        }
    }
}
