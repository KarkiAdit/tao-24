//
//  SchemaV1.swift
//  tao-24
//

import Foundation
import SwiftData

/// Version 1 of the persistent schema.
///
/// Declaring a `VersionedSchema` from the first version costs almost nothing
/// now and is the difference between a one-line migration stage and a manual
/// store rebuild later. `DatabaseService` builds its `ModelContainer` from
/// this rather than from a bare model list.
///
/// **When V2 arrives**, the model types must be *snapshotted* into it — copied
/// as nested types describing the old shape — rather than left pointing at the
/// live classes. Referencing live types works only while there is exactly one
/// version, because the live class always describes the newest shape and a
/// migration needs to know the old one.
enum SchemaV1: VersionedSchema {

    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [
            Habit.self,
            HabitExecutionLog.self,
            LifeGoal.self,
            UserValueProfile.self,
        ]
    }
}
