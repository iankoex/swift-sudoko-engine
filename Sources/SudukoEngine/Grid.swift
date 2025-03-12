//
//  SudokuGrid.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//

/// Extends the Sudoku structure to include the SudokuGrid type.
/// A SudokuGrid represents one of the 9 boxes (3x3 regions) in a Sudoku puzzle.
public extension Sudoku {

    /// A structure representing one of the 9 boxes or regions in a Sudoku puzzle.
    /// Each grid corresponds to a 3x3 region and holds 9 cells.
    struct SudokuGrid {
        /// The position of this grid in the overall Sudoku puzzle (1-9).
        /// The grids are numbered from left to right, top to bottom as follows:
        /// 1 2 3
        /// 4 5 6
        /// 7 8 9
        public var position: Int

        /// The collection of 9 cells within this grid.
        public var cells: [Cell]

        /// Initializes a new SudokuGrid.
        ///
        /// - Parameters:
        ///   - position: The position of this grid in the overall puzzle (must be in the range 1-9).
        ///   - cells: An array of Cell objects representing the 9 cells within the grid.
        ///            If provided, the count must be exactly 9.
        ///
        /// - Throws: A `SudokuError` if the position is not between 1 and 9 or if the cell count is not 9.
        public init(position: Int, cells: [Cell] = []) throws {
            // Validate that the grid position is within 1 to 9.
            if position < 1 || position > 9 {
                throw SudokuError.invalidGridPosition(position: position)
            }

            // Validate that if cells are provided, there are exactly 9 of them.
            if !cells.isEmpty && cells.count != 9 {
                throw SudokuError.invalidCellCount(count: cells.count)
            }

            self.position = position
            self.cells = cells
        }

        /// Creates an empty SudokuGrid at the specified position.
        ///
        /// This method initializes a grid with all cell values set to 0. The cells are arranged
        /// in a 3x3 block, and the method calculates the corresponding global positions for each cell.
        ///
        /// - Parameter position: The position of the grid in the overall Sudoku puzzle (1-9).
        /// - Returns: A fully initialized SudokuGrid with all cell values set to 0.
        /// - Throws: A `SudokuError` if the specified position is invalid or if cell creation fails.
        public static func createEmpty(position: Int) throws -> SudokuGrid {
            // Validate that the grid position is within the allowed range (1 to 9).
            if position < 1 || position > 9 {
                throw SudokuError.invalidGridPosition(position: position)
            }

            // Adjust the position to a 0-based index for calculation purposes.
            let adjustedPosition = position - 1

            // Calculate the row and column of the grid within the overall puzzle.
            // Each grid is arranged in a 3x3 layout.
            // Example: For position 5 (adjusted position 4), gridRow is 1 and gridCol is 1.
            let gridRow = adjustedPosition / 3  // Values will be 0, 1, or 2.
            let gridCol = adjustedPosition % 3  // Values will be 0, 1, or 2.

            var cells = [Cell]()

            // Build the grid by iterating through local positions within the 3x3 grid.
            // localRow and localCol represent the local coordinates (0, 1, 2) within the 3x3 grid.
            for localRow in 0..<3 {
                for localCol in 0..<3 {
                    // Calculate the global row and column in the overall Sudoku puzzle.
                    let globalRow = (gridRow * 3) + localRow
                    let globalCol = (gridCol * 3) + localCol

                    // Convert the global column to its corresponding letter (A-I).
                    let column = String(
                        UnicodeScalar("A".unicodeScalars.first!.value + UInt32(globalCol))!
                    )
                    // Global row is displayed as numbers from 1 to 9.
                    let row = String(globalRow + 1)

                    // Create a new cell with default value 0 using the calculated positions.
                    do {
                        cells.append(try Cell(column: column, row: row, value: 0))
                    } catch {
                        // This error should not occur for the default value of 0.
                        throw error
                    }
                }
            }

            // Return a new SudokuGrid instance with the initialized empty cells.
            return try SudokuGrid(position: position, cells: cells)
        }
    }
}
