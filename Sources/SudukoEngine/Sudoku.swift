//
//  Sudoku.swift
//  swift-suduko-engine
//
//  Created by ian on 11/03/2025.
//

/// A structure representing a full Sudoku puzzle.
///
/// A standard Sudoku puzzle is composed of 9 distinct grids (often
/// visualized as 3x3 boxes). Each grid contains 9 cells, and the entire puzzle
/// must satisfy the rules of Sudoku.
public struct Sudoku: Sendable {

    /// The collection of 9 grids that make up the complete Sudoku puzzle.
    /// Each grid holds a subset of cells corresponding to one of the nine boxes.
    public var grid: [SudokuGrid]

    /// The difficulty level of the Sudoku puzzle.
    public var difficulty: Difficulty

    /// Initializes a new Sudoku puzzle.
    ///
    /// - Parameters:
    ///   - grid: An array of SudokuGrid objects representing the 9 boxes of the Sudoku puzzle.
    ///           If an empty array is provided, no grid count validation is performed.
    ///   - difficulty: The difficulty level of the Sudoku puzzle.
    ///
    /// - Throws:
    ///   - `SudokuError.invalidGridCount` if grids are provided but their count is not exactly 9.
    ///   - `SudokuError.invalidGridPosition` if any grid's position is not within the valid range (1-9).
    ///   - `SudokuError.duplicateGridPosition` if there are duplicate positions among the grids.
    public init(
        grid: [SudokuGrid] = [],
        difficulty: Difficulty
    ) throws {
        // If grids are provided, validate that there are exactly 9 grids.
        if !grid.isEmpty && grid.count != 9 {
            throw SudokuError.invalidGridCount(count: grid.count)
        }

        // Check that each grid's position is within 1...9 and that no positions are duplicated.
        var seenPositions = Set<Int>()
        for sudokuGrid in grid {
            // Validate grid position is within the allowed range.
            if sudokuGrid.position < 1 || sudokuGrid.position > 9 {
                throw SudokuError.invalidGridPosition(position: sudokuGrid.position)
            }

            // Ensure that the grid position hasn't been used already.
            if seenPositions.contains(sudokuGrid.position) {
                throw SudokuError.duplicateGridPosition(position: sudokuGrid.position)
            }

            seenPositions.insert(sudokuGrid.position)
        }

        self.grid = grid
        self.difficulty = difficulty
    }

    /// Creates an empty Sudoku puzzle with all grids and cells set to their initial values (typically 0).
    ///
    /// This is a convenience computed property that initializes a complete board where
    /// each sub-grid is generated using `SudokuGrid.createEmpty(position:)` with positions 1 through 9.
    ///
    /// - Returns: A fully initialized Sudoku puzzle with all values set to 0, and with a default difficulty of `.easy`.
    public static var empty: Sudoku {
        // Initialize an empty array to hold grids.
        var grids: [SudokuGrid] = []

        // Loop through positions 1 to 9 and create an empty grid for each.
        for position in 1...9 {
            do {
                grids.append(try SudokuGrid.createEmpty(position: position))
            } catch {
                // This should never happen because the positions are known to be valid in the range 1...9.
                fatalError("Failed to create empty Sudoku grid: \(error)")
            }
        }

        // Create and return a Sudoku instance using the created grids.
        do {
            return try Sudoku(grid: grids, difficulty: .easy)
        } catch {
            // This should also never happen if the grids are correctly created.
            fatalError("Failed to create empty Sudoku: \(error)")
        }
    }
}

public extension Sudoku {
    /// A computed property that flattens all the cells from every grid in the Sudoku puzzle
    /// into a single array.
    ///
    /// - Returns: An array of all `SudokuGrid.Cell` elements from every grid in the puzzle.
    ///
    /// - Note: Cells with a value of 0 are considered empty cells. If you only need cells with
    /// non-zero values or cells meeting certain conditions, you may need to filter the resulting array.
    var allCells: [SudokuGrid.Cell] {
        return grid.flatMap { $0.cells.map { $0 } }
    }
}


extension Sudoku {
    /// Returns the cells that are invalid due to duplicate non-zero values.
    ///
    /// A cell is considered invalid if:
    ///  - In its 3x3 grid, there is another cell carrying the same non-zero value.
    ///  - In its global row (as indicated by its row identifier) there is another cell
    ///    with the same non-zero value.
    ///  - In its global column (as indicated by its column identifier) there is another cell
    ///    with the same non-zero value.
    ///
    /// - Returns: An array of SudokuGrid.Cell objects that are involved in any duplicate.
    public func invalidCells() -> [SudokuGrid.Cell] {
        // Get all cells in the puzzle.
        let cells = self.allCells
        // We only care about non-zero cells.
        let nonZeroCells = cells.filter { $0.value != 0 }

        // Dictionaries to track cells per row, per column, and per grid.
        // The dictionaries will map a key (row, column, or grid id) combined with a cell value
        // to an array of cells having that same value.
        var rowGroups = [String: [Int: [SudokuGrid.Cell]]]()  // row -> value -> cells
        var colGroups = [String: [Int: [SudokuGrid.Cell]]]()  // column -> value -> cells
        var gridGroups = [Int: [Int: [SudokuGrid.Cell]]]()     // grid position -> value -> cells

        // The grid identifier for a cell is inferred from the 3x3 box it belongs to.
        // Since we initialized the grid with a specific "row" and "column" value,
        // we need a helper that finds out in which grid the cell belongs.
        //
        // One way to do that is to use the known mapping in the engine: the global row (1-9)
        // and column (A-I) determine the box. In our puzzle, the rows are numbered 1 through 9 and
        // the columns are letters "A" through "I". We can compute an index by converting the column letter to a number,
        // grouping rows and columns in groups of 3.
        func gridIdentifier(for cell: SudokuGrid.Cell) -> Int? {
            guard let colValue = cell.column.unicodeScalars.first?.value,
                  let rowInt = Int(cell.row) else { return nil }
            // Columns: A -> 0, B -> 1, ..., I -> 8.
            let colIndex = Int(colValue - UnicodeScalar("A").value)
            let rowIndex = rowInt - 1  // Make it 0-based.

            // Determine which grid this cell belongs to by computing the row and column of the grid.
            let gridRow = rowIndex / 3   // 0, 1, or 2.
            let gridCol = colIndex / 3   // 0, 1, or 2.
                                         // Grids are numbered from 1 to 9 left-to-right, top-to-bottom:
                                         // gridId = gridRow * 3 + gridCol + 1.
            return gridRow * 3 + gridCol + 1
        }

        // Populate groups.
        for cell in nonZeroCells {
            // Group by row.
            rowGroups[cell.row, default: [:]][cell.value, default: []].append(cell)

            // Group by column.
            colGroups[cell.column, default: [:]][cell.value, default: []].append(cell)

            // Group by grid (if we can calculate it).
            if let gridId = gridIdentifier(for: cell) {
                gridGroups[gridId, default: [:]][cell.value, default: []].append(cell)
            }
        }

        // A set to track invalid cell IDs (we use the cell's id property).
        var invalidCellIDs = Set<String>()

        // Helper function to process groups and mark duplicates.
        func markInvalid(from groups: [Any]) {
            // We won't use this function formally because the groups are of different types.
            // Instead, we will manually process rowGroups, colGroups, and gridGroups.
        }

        // Check duplicates in rows.
        for (_, valueDict) in rowGroups {
            for (_, cellsArray) in valueDict where cellsArray.count > 1 {
                for cell in cellsArray {
                    invalidCellIDs.insert(cell.id)
                }
            }
        }

        // Check duplicates in columns.
        for (_, valueDict) in colGroups {
            for (_, cellsArray) in valueDict where cellsArray.count > 1 {
                for cell in cellsArray {
                    invalidCellIDs.insert(cell.id)
                }
            }
        }

        // Check duplicates in grids.
        for (_, valueDict) in gridGroups {
            for (_, cellsArray) in valueDict where cellsArray.count > 1 {
                for cell in cellsArray {
                    invalidCellIDs.insert(cell.id)
                }
            }
        }

        // Return the full cell objects that are marked invalid.
        // Since ids are strings, we can filter the original nonZeroCells.
        let invalid = nonZeroCells.filter { invalidCellIDs.contains($0.id) }
        return invalid
    }
}
