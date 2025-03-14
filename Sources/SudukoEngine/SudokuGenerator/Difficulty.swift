//
//  Difficulty.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//


// MARK: - Difficulty Level Enum

extension Sudoku {
    /// The level of difficulty for a Sudoku puzzle.
    public enum Difficulty: Sendable {
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
