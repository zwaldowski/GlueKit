//
//  SetMappingForArrayField.swift
//  GlueKit
//
//  Created by Károly Lőrentey on 2016-10-07.
//  Copyright © 2016. Károly Lőrentey. All rights reserved.
//

extension ObservableSetType {
    public func flatMap<Field: ObservableArrayType>(_ key: @escaping (Element) -> Field) -> AnyObservableSet<Field.Element> where Field.Element: Hashable {
        return SetMappingForArrayField<Self, Field>(parent: self, key: key).anyObservableSet
    }
}

class SetMappingForArrayField<Parent: ObservableSetType, Field: ObservableArrayType>: SetMappingBase<Field.Element> where Field.Element: Hashable {
    let parent: Parent
    let key: (Parent.Element) -> Field

    init(parent: Parent, key: @escaping (Parent.Element) -> Field) {
        self.parent = parent
        self.key = key
        super.init()
        parent.updates.add(parentSink)

        for e in parent.value {
            let field = key(e)
            field.updates.add(fieldSink)
            for new in field.value {
                _ = self.insert(new)
            }
        }
    }

    deinit {
        parent.updates.remove(parentSink)
        for e in parent.value {
            let field = key(e)
            field.updates.remove(fieldSink)
        }
    }

    private var parentSink: AnySink<SetUpdate<Parent.Element>> {
        return StrongMethodSink(owner: self, identifier: 1, method: SetMappingForArrayField.applyParentUpdate).anySink
    }

    private var fieldSink: AnySink<ArrayUpdate<Field.Element>> {
        return StrongMethodSink(owner: self, identifier: 2, method: SetMappingForArrayField.applyFieldUpdate).anySink
    }

    private func applyParentUpdate(_ update: SetUpdate<Parent.Element>) {
        switch update {
        case .beginTransaction:
            beginTransaction()
        case .change(let change):
            var transformedChange = SetChange<Element>()
            for e in change.removed {
                let field = key(e)
                field.updates.remove(fieldSink)
                for r in field.value {
                    if self.remove(r) {
                        transformedChange.remove(r)
                    }
                }
            }
            for e in change.inserted {
                let field = key(e)
                field.updates.add(fieldSink)
                for i in field.value {
                    if self.insert(i) {
                        transformedChange.insert(i)
                    }
                }
            }
            if !transformedChange.isEmpty {
                sendChange(transformedChange)
            }
        case .endTransaction:
            endTransaction()
        }
    }

    private func applyFieldUpdate(_ update: ArrayUpdate<Field.Element>) {
        switch update {
        case .beginTransaction:
            beginTransaction()
        case .change(let change):
            var transformedChange = SetChange<Element>()
            change.forEachOld { old in
                if self.remove(old) {
                    transformedChange.remove(old)
                }
            }
            change.forEachNew { new in
                if self.insert(new) {
                    transformedChange.insert(new)
                }
            }
            transformedChange = transformedChange.removingEqualChanges()
            if !transformedChange.isEmpty {
                sendChange(transformedChange)
            }
        case .endTransaction:
            endTransaction()
        }
    }
}
