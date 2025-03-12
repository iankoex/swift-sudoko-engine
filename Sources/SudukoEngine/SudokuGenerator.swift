//
//  SudokuGenerator.swift
//  swift-suduko-engine
//
//  Created by ian on 11/03/2025.
//

import Foundation

// MARK: - Difficulty Level Enum

/// The level of difficulty for a Sudoku puzzle.
public enum Difficulty {
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

// MARK: - Sudoku Generator

/// A class that generates Sudoku puzzles asynchronously according to a given difficulty.
///
/// This generator:
/// • Generates a fully solved puzzle using backtracking.
/// • Removes cells from the solved puzzle based on the chosen difficulty (while maintaining symmetry).
/// • Ensures a unique solution: when attempting to remove a cell the generator first checks if the puzzle
///   still has only one solution. If not, the candidate cells are marked as non-removable.
public class SudokuGenerator {

    /// Generates a complete Sudoku puzzle asynchronously.
    /// - Parameter difficulty: The difficulty level (easy, medium, or hard) determining how many cells will be removed.
    /// - Returns: A Sudoku puzzle with a unique solution that adheres to design qualities.
    public func generateSudoku(difficulty: Difficulty) async throws -> Sudoku {
        // Step 1: Generate a completely solved puzzle.
        let solvedSudoku = try await generateSolvedSudoku()
        print("Solved Sudoku:")
        print(solvedSudoku)

        // Step 2: Remove cells according to difficulty while preserving symmetry and uniqueness.
        let puzzle = try await removeCells(from: solvedSudoku, removalCount: difficulty.removalCount)

        return puzzle
    }

    // MARK: - Private Helper Methods

    /// Asynchronously generates a complete solved Sudoku puzzle using backtracking.
    /// - Returns: A fully solved Sudoku puzzle.
    private func generateSolvedSudoku() async throws -> Sudoku {
        // Create a 9x9 board filled with 0s for backtracking.
        var board = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)

        /// Checks whether placing a number is valid.
        func isValid(_ board: [[Int]], row: Int, col: Int, num: Int) -> Bool {
            // Check the row and column.
            for i in 0..<9 {
                if board[row][i] == num || board[i][col] == num {
                    return false
                }
            }
            // Check the 3x3 sub-grid.
            let startRow = row - row % 3, startCol = col - col % 3
            for i in 0..<3 {
                for j in 0..<3 {
                    if board[startRow + i][startCol + j] == num {
                        return false
                    }
                }
            }
            return true
        }

        /// Backtracking solver function.
        func solve(_ board: inout [[Int]], row: Int, col: Int) -> Bool {
            if row == 9 { return true }
            let nextRow = col == 8 ? row + 1 : row
            let nextCol = (col + 1) % 9
            if board[row][col] != 0 {
                return solve(&board, row: nextRow, col: nextCol)
            }
            // Shuffle the numbers to produce a random board.
            var numbers = Array(1...9)
            numbers.shuffle()
            for num in numbers {
                if isValid(board, row: row, col: col, num: num) {
                    board[row][col] = num
                    if solve(&board, row: nextRow, col: nextCol) {
                        return true
                    }
                    board[row][col] = 0
                }
            }
            return false
        }

        // Solve the board.
        guard solve(&board, row: 0, col: 0) else {
            throw NSError(domain: "SudokuGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate a solved Sudoku board."])
        }

        // Convert the 2D board back into a Sudoku structure.
        var newGrids = [Sudoku.SudokuGrid]()
        for gridPos in 1...9 {
            let grid = try Sudoku.SudokuGrid.createEmpty(position: gridPos)
            newGrids.append(grid)
        }
        var newSudoku = try Sudoku(grid: newGrids)

        // Map each number from the board to the corresponding cell in newSudoku.
        for row in 0..<9 {
            for col in 0..<9 {
                let columnLetter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(col))!)
                let rowLetter = String(row + 1)
                for gridIndex in 0..<newSudoku.grid.count {
                    for cellIndex in 0..<newSudoku.grid[gridIndex].cells.count {
                        let cell = newSudoku.grid[gridIndex].cells[cellIndex]
                        if cell.column == columnLetter && cell.row == rowLetter {
                            newSudoku.grid[gridIndex].cells[cellIndex].value = board[row][col]
                        }
                    }
                }
            }
        }

        return newSudoku
    }

    /// Counts the number of solutions for a given board using a modified backtracking algorithm.
    ///
    /// - Parameters:
    ///   - board: A 9x9 Sudoku board represented as a 2D array of Int (where 0 represents an empty cell).
    ///   - limit: The maximum number of solutions to search for (default 2).
    /// - Returns: The number of solutions found (up to the limit).
    private func countSolutions(for board: inout [[Int]], limit: Int = 2) -> Int {
        var solutionCount = 0

        /// Checks if placing a number is valid (repeated here in the closure).
        func isValid(_ board: [[Int]], row: Int, col: Int, num: Int) -> Bool {
            for i in 0..<9 {
                if board[row][i] == num || board[i][col] == num {
                    return false
                }
            }
            let startRow = row - row % 3, startCol = col - col % 3
            for i in 0..<3 {
                for j in 0..<3 {
                    if board[startRow + i][startCol + j] == num {
                        return false
                    }
                }
            }
            return true
        }

        /// The recursive backtracking function that counts solutions.
        func solve(_ board: inout [[Int]], row: Int, col: Int) {
            if solutionCount >= limit { return }
            if row == 9 {
                solutionCount += 1
                return
            }

            let nextRow = col == 8 ? row + 1 : row
            let nextCol = (col + 1) % 9

            if board[row][col] != 0 {
                solve(&board, row: nextRow, col: nextCol)
                return
            }

            for num in 1...9 {
                if isValid(board, row: row, col: col, num: num) {
                    board[row][col] = num
                    solve(&board, row: nextRow, col: nextCol)
                    board[row][col] = 0
                }
            }
        }

        solve(&board, row: 0, col: 0)
        return solutionCount
    }

    /// Asynchronously removes cells from a solved Sudoku board to create a puzzle.
    ///
    /// This method removes cells in pairs preserving symmetry and ensures that each removal
    /// does not create multiple solutions. If removing a candidate pair produces multiple solutions,
    /// then those cells are marked as nonremovable.
    ///
    /// - Parameters:
    ///   - sudoku: A fully solved Sudoku puzzle.
    ///   - removalCount: The total number of cells to remove.
    /// - Returns: A modified Sudoku puzzle with removed cells (set to 0) that has a unique solution.
    private func removeCells(from sudoku: Sudoku, removalCount: Int) async throws -> Sudoku {
        // Copy the solved puzzle.
        var puzzle = sudoku

        // Create a mutable 9x9 board from the puzzle structure.
        var board = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
        for row in 0..<9 {
            for col in 0..<9 {
                let columnLetter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(col))!)
                let rowLetter = String(row + 1)
                for grid in puzzle.grid {
                    if let cell = grid.cells.first(where: { $0.column == columnLetter && $0.row == rowLetter }) {
                        board[row][col] = cell.value
                    }
                }
            }
        }

        var removed = 0

        // Use a set to store candidate cells (and their symmetric mates) that cannot be removed.
        // We'll store coordinates as (row, col) pairs.
        var cannotRemove = Set<[Int]>()  // each element: [row, col]

        // A helper function to test if a candidate coordinate is locked.
        func isLocked(row: Int, col: Int) -> Bool {
            return cannotRemove.contains([row, col])
        }

        // Continue removing cells until we have removed the target count or we have no further candidates.
        while removed < removalCount {
            // Randomly pick a candidate cell that isn't already removed and that is not locked.
            let row = Int.random(in: 0..<9)
            let col = Int.random(in: 0..<9)
            let symRow = 8 - row
            let symCol = 8 - col

            // Skip if either candidate is already removed or been marked as nonremovable.
            if board[row][col] == 0 || board[symRow][symCol] == 0 ||
                isLocked(row: row, col: col) || isLocked(row: symRow, col: symCol) {
                continue
            }

            // Temporarily remove the candidate cells.
            let backup1 = board[row][col]
            let backup2 = board[symRow][symCol]
            board[row][col] = 0
            board[symRow][symCol] = 0

            // Count solutions with the updated board.
            var boardCopy = board  // Make a copy since countSolutions works in place.
            let solCount = countSolutions(for: &boardCopy, limit: 2)

            if solCount == 1 {
                // Removal is successful; update count.
                removed += 2
            } else {
                // Undo removal and mark these cells as nonremovable.
                board[row][col] = backup1
                board[symRow][symCol] = backup2
                cannotRemove.insert([row, col])
                cannotRemove.insert([symRow, symCol])
            }

            // If too many cells are locked and no more removals can be made, then break.
            if cannotRemove.count >= 81 {
                break
            }
        }

        // Map the modified board back to the Sudoku structure.
        for row in 0..<9 {
            for col in 0..<9 {
                let columnLetter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(col))!)
                let rowLetter = String(row + 1)
                for gridIndex in 0..<puzzle.grid.count {
                    for cellIndex in 0..<puzzle.grid[gridIndex].cells.count {
                        let cell = puzzle.grid[gridIndex].cells[cellIndex]
                        if cell.column == columnLetter && cell.row == rowLetter {
                            puzzle.grid[gridIndex].cells[cellIndex].value = board[row][col]
                        }
                    }
                }
            }
        }

        return puzzle
    }
}
