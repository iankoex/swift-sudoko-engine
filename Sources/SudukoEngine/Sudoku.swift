//
//  Sudoku.swift
//  swift-suduko-engine
//
//  Created by ian on 11/03/2025.
//

import Foundation

/// A structure representing a full Sudoku puzzle.
/// A standard Sudoku consists of 9 grids (3x3 boxes), each containing 9 cells.
public struct Sudoku: CustomStringConvertible {
    /// The collection of 9 grids that make up the complete Sudoku puzzle.
    public var grid: [SudokuGrid]

    /// Initializes a new Sudoku puzzle.
    /// - Parameter grid: An array of SudokuGrid objects representing the 9 boxes of the Sudoku puzzle.
    /// - Throws: SudokuError.invalidGridCount if the grid count is not 9
    public init(grid: [SudokuGrid] = []) throws {
        // Check that we have exactly 9 grids if any are provided
        if !grid.isEmpty && grid.count != 9 {
            throw SudokuError.invalidGridCount(count: grid.count)
        }

        // Check that grid positions are valid (1-9) and unique
        var seenPositions = Set<Int>()
        for sudokuGrid in grid {
            if sudokuGrid.position < 1 || sudokuGrid.position > 9 {
                throw SudokuError.invalidGridPosition(position: sudokuGrid.position)
            }

            if seenPositions.contains(sudokuGrid.position) {
                throw SudokuError.duplicateGridPosition(position: sudokuGrid.position)
            }

            seenPositions.insert(sudokuGrid.position)
        }

        self.grid = grid
    }

    /// Creates an empty Sudoku puzzle with all grids and cells initialized with zero values.
    /// - Returns: A fully initialized Sudoku puzzle with all values set to 0.
    public static var empty: Sudoku {
        var grids: [SudokuGrid] = []
        for position in 1...9 {
            do {
                grids.append(try SudokuGrid.createEmpty(position: position))
            } catch {
                // This should never happen with the range 1...9
                fatalError("Failed to create empty Sudoku grid: \(error)")
            }
        }

        do {
            return try Sudoku(grid: grids)
        } catch {
            // This should never happen with properly created grids
            fatalError("Failed to create empty Sudoku: \(error)")
        }
    }

    /// A custom string representation of the Sudoku puzzle.
    /// Returns all cells in the format "A1:0 B1:0 C1:0 ..."
    /// organized by rows for better readability.
    public var description: String {
        // Create a dictionary to store all cells by their coordinates
        var cellsByCoordinate: [String: Int] = [:]

        // Collect all cells from all grids
        for sudokuGrid in grid {
            for cell in sudokuGrid.cells {
                let coordinate = "\(cell.column)\(cell.row)"
                cellsByCoordinate[coordinate] = cell.value
            }
        }

        // Create ordered arrays of columns and rows
        let columns = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
        let rows = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

        // Build the string representation row by row
        var result = ""
        for row in rows {
            var rowString = ""
            for column in columns {
                let coordinate = "\(column)\(row)"
                let value = cellsByCoordinate[coordinate] ?? 0
                rowString += "\(coordinate):\(value) "
            }
            result += rowString.trimmingCharacters(in: .whitespaces) + "\n"
        }

        return result.trimmingCharacters(in: .newlines)
    }
}

public extension Sudoku {
    /// A structure representing one of the 9 boxes (3x3 regions) in a Sudoku puzzle.
    struct SudokuGrid: CustomStringConvertible {
        /// The position of this grid in the overall Sudoku puzzle (1-9).
        /// Positions are numbered from left to right, top to bottom:
        /// 1 2 3
        /// 4 5 6
        /// 7 8 9
        public var position: Int

        /// The collection of 9 cells within this grid.
        public var cells: [Cell]

        /// Initializes a new SudokuGrid.
        /// - Parameters:
        ///   - position: The position of this grid in the overall Sudoku puzzle (1-9).
        ///   - cells: An array of Cell objects representing the 9 cells within this grid.
        /// - Throws: SudokuError if position or cells are invalid
        public init(position: Int, cells: [Cell] = []) throws {
            // Validate position is between 1-9
            if position < 1 || position > 9 {
                throw SudokuError.invalidGridPosition(position: position)
            }

            // Validate cell count if provided
            if !cells.isEmpty && cells.count != 9 {
                throw SudokuError.invalidCellCount(count: cells.count)
            }

            self.position = position
            self.cells = cells
        }

        /// Creates an empty grid at the specified position with all cell values set to 0.
        /// - Parameter position: The position of this grid in the overall Sudoku puzzle (1-9).
        /// - Returns: A fully initialized SudokuGrid with all cell values set to 0.
        /// - Throws: SudokuError if position is invalid
        public static func createEmpty(position: Int) throws -> SudokuGrid {
            // Validate position is between 1-9
            if position < 1 || position > 9 {
                throw SudokuError.invalidGridPosition(position: position)
            }

            // Adjust position to 0-based for calculation (position-1)
            let adjustedPosition = position - 1

            // Calculate the starting row and column for this grid in the overall puzzle
            let gridRow = adjustedPosition / 3  // 0, 1, or 2
            let gridCol = adjustedPosition % 3  // 0, 1, or 2

            var cells = [Cell]()

            for localRow in 0..<3 {
                for localCol in 0..<3 {
                    // Convert local position to global position
                    let globalRow = (gridRow * 3) + localRow
                    let globalCol = (gridCol * 3) + localCol

                    // Column is represented as A-I
                    let column = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(globalCol))!)
                    // Row is represented as 1-9
                    let row = String(globalRow + 1)

                    do {
                        cells.append(try Cell(column: column, row: row, value: 0))
                    } catch {
                        // This should never happen with value=0
                        throw error
                    }
                }
            }

            return try SudokuGrid(position: position, cells: cells)
        }

        /// A custom string representation of the SudokuGrid.
        /// Returns all cells in the format "A1:0 B2:0 ..."
        public var description: String {
            var result = "Grid \(position): "
            for cell in cells {
                result += "\(cell.description) "
            }
            return result.trimmingCharacters(in: .whitespaces)
        }
    }
}

public extension Sudoku.SudokuGrid {
    /// A structure representing an individual cell within a Sudoku grid.
    struct Cell: CustomStringConvertible {
        /// The column identifier for this cell in the overall Sudoku puzzle (A-I).
        public var column: String

        /// The row identifier for this cell in the overall Sudoku puzzle (1-9).
        public var row: String

        /// The current value in this cell (0-9, where 0 represents an empty cell).
        public var value: Int

        /// Initializes a new Cell with the specified properties.
        /// - Parameters:
        ///   - column: The column identifier (A-I) for this cell.
        ///   - row: The row identifier (1-9) for this cell.
        ///   - value: The value of the cell (0-9, where 0 represents an empty cell).
        /// - Throws: SudokuError if value is not between 0-9
        public init(column: String, row: String, value: Int) throws {
            // Validate value is between 0-9
            if value < 0 || value > 9 {
                throw SudokuError.invalidCellValue(value: value)
            }

            // Validate column is a single character between A-I
            if column.count != 1 || !("A"..."I").contains(column) {
                throw SudokuError.invalidColumnIdentifier(column: column)
            }

            // Validate row is a single character between 1-9
            if row.count != 1 || !("1"..."9").contains(row) {
                throw SudokuError.invalidRowIdentifier(row: row)
            }

            self.column = column
            self.row = row
            self.value = value
        }

        /// A custom string representation of the Cell.
        /// Returns in the format "A1:0" (column+row:value).
        public var description: String {
            return "\(column)\(row):\(value)"
        }
    }
}

/// Errors that can occur when working with a Sudoku puzzle.
public enum SudokuError: Error {
    /// Thrown when a cell value is not between 0-9.
    case invalidCellValue(value: Int)

    /// Thrown when a grid position is not between 1-9.
    case invalidGridPosition(position: Int)

    /// Thrown when a grid doesn't contain exactly 9 cells.
    case invalidCellCount(count: Int)

    /// Thrown when a Sudoku doesn't contain exactly 9 grids.
    case invalidGridCount(count: Int)

    /// Thrown when a grid position is duplicated.
    case duplicateGridPosition(position: Int)

    /// Thrown when a column identifier is not A-I.
    case invalidColumnIdentifier(column: String)

    /// Thrown when a row identifier is not 1-9.
    case invalidRowIdentifier(row: String)
}

// Add CustomStringConvertible to provide human-readable error messages
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
        }
    }
}
