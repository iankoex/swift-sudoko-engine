//
//  Difficulty.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//


// MARK: - Difficulty Level Enum

extension Sudoku {
    /// The level of difficulty for a Sudoku puzzle.
    public enum Difficulty: Sendable, CaseIterable {
        case easy
        case medium
        case hard

        /// The number of cells to remove according to the difficulty.
        var removalCount: Int {
            switch self {
                case .easy:
                    return 30  // fewer cells removed: more givens
                case .medium:
                    return 40
                case .hard:
                    return 50  // more cells removed: fewer givens
            }
        }

        /// An optional factor for symmetry (not used directly in removalRate but can be used to guide removal for symmetry).
        var symmetry: Bool {
            return true
        }
    }
}

extension Sudoku.Difficulty: CustomStringConvertible {
    /// A human-readable description of the difficulty level.
    ///
    /// - Returns: A `String` representing the difficulty level in a user-friendly format.
    ///   For example, "Easy", "Medium", or "Hard".
    public var description: String {
        switch self {
            case .easy:
                return "Easy"
            case .medium:
                return "Medium"
            case .hard:
                return "Hard"
        }
    }
}

extension Sudoku.Difficulty: Identifiable {
    /// A unique identifier for each difficulty level.
    ///
    /// - Returns: A `String` identifier that uses the description of the difficulty.
    ///   This ensures that each difficulty level (Easy, Medium, Hard) has a unique, human-readable ID.
    public var id: String {
        return self.description
    }
}
