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
public struct Sudoku {

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
