//
//  TaoMigrationPlan.swift
//  tao-24
//

import Foundation
import SwiftData

/// The store's migration history.
///
/// One version, so there are no stages yet. It exists from the start anyway:
/// wiring a migration plan into the container now means V2 adds a stage, while
/// retrofitting one later means reasoning about stores that were created
/// without a recorded version.
enum TaoMigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
