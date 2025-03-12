//
//  SudokuError.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//

/// Errors that can occur when working with a Sudoku puzzle.
///
/// This enumeration defines specific error cases that may be thrown during
/// the creation and manipulation of Sudoku puzzles, grids, and cells.
public enum SudokuError: Error {
    /// Thrown when a cell value is not between 0 and 9.
    case invalidCellValue(value: Int)

    /// Thrown when a grid position is not between 1 and 9.
    case invalidGridPosition(position: Int)

    /// Thrown when a grid doesn't contain exactly 9 cells.
    case invalidCellCount(count: Int)

    /// Thrown when a Sudoku puzzle doesn't contain exactly 9 grids.
    case invalidGridCount(count: Int)

    /// Thrown when a grid position is duplicated within a Sudoku puzzle.
    case duplicateGridPosition(position: Int)

    /// Thrown when a column identifier is not in the range A-I.
    case invalidColumnIdentifier(column: String)

    /// Thrown when a row identifier is not in the range 1-9.
    case invalidRowIdentifier(row: String)

    /// Thrown when the generation of a Sudoku puzzle fails.
    case generationFailure
}


/// Extend SudokuError to provide human-readable error messages.
///
/// This extension conforms the error type to CustomStringConvertible,
/// enabling a descriptive string representation for each error case.
extension SudokuError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .invalidCellValue(let value):
                return "Cell value must be between 0-9, got \(value)"
            case .invalidGridPosition(let position):
                return "Grid position must be between 1-9, got \(position)"
            case .invalidCellCount(let count):
                return "Each grid must contain exactly 9 cells, got \(count)"
            case .invalidGridCount(let count):
                return "A Sudoku puzzle must contain exactly 9 grids, got \(count)"
            case .duplicateGridPosition(let position):
                return "Duplicate grid position: \(position)"
            case .invalidColumnIdentifier(let column):
                return "Column identifier must be A-I, got '\(column)'"
            case .invalidRowIdentifier(let row):
                return "Row identifier must be 1-9, got '\(row)'"
            case .generationFailure:
                return "Failed to generate a valid Sudoku puzzle"
        }
    }
}
