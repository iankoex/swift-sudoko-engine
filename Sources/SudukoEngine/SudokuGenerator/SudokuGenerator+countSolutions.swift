//
//  File.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//

extension SudokuGenerator {
    /// Counts the number of solutions for a given board using a modified backtracking algorithm.
    ///
    /// - Parameters:
    ///   - board: A 9x9 Sudoku board represented as a 2D array of Int (where 0 represents an empty cell).
    ///   - limit: The maximum number of solutions to search for (default 2).
    /// - Returns: The number of solutions found (up to the limit).
    public static func countSolutions(for board: inout [[Int]], limit: Int = 2) -> Int {
        var solutionCount = 0

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

}
