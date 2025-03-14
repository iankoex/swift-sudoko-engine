//
//  Cell.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//

// Extend SudokuGrid (which belongs to Sudoku) with a Cell type.
public extension Sudoku.SudokuGrid {

    /// A structure representing an individual cell within a Sudoku grid.
    /// Each cell is identified by its column (A-I) and row (1-9) and holds a numeric value.
    struct Cell: Sendable {
        /// The column identifier for this cell in the overall Sudoku puzzle (A-I).
        public var column: String

        /// The row identifier for this cell in the overall Sudoku puzzle (1-9).
        public var row: String

        /// The current value in this cell (0-9, where 0 represents an empty cell).
        public var value: Int

        /// Initializes a new Cell with the specified properties.
        ///
        /// - Parameters:
        ///   - column: The column identifier for this cell. It must be a single character between A and I.
        ///   - row: The row identifier for this cell. It must be a single character between 1 and 9.
        ///   - value: The value of the cell, where 0 represents an empty cell and 1-9 are valid cell values.
        ///
        /// - Throws: A `SudokuError` if:
        ///   - The value is not between 0 and 9.
        ///   - The column identifier is not a single character between A and I.
        ///   - The row identifier is not a single character between 1 and 9.
        public init(column: String, row: String, value: Int) throws {
            // Validate that the cell's value is between 0 and 9.
            if value < 0 || value > 9 {
                throw SudokuError.invalidCellValue(value: value)
            }

            // Validate the column identifier:
            // It must be exactly one character and in the range A through I.
            if column.count != 1 || !("A"..."I").contains(column) {
                throw SudokuError.invalidColumnIdentifier(column: column)
            }

            // Validate the row identifier:
            // It must be exactly one character and in the range 1 through 9.
            if row.count != 1 || !("1"..."9").contains(row) {
                throw SudokuError.invalidRowIdentifier(row: row)
            }

            self.column = column
            self.row = row
            self.value = value
        }
    }
}

extension Sudoku.SudokuGrid.Cell: Identifiable {
    public var id: String {
        return column.appending(row)
    }
}
