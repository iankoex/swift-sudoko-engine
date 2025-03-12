//
//  File.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//

extension SudokuGenerator {

    /// Checks whether placing a number is valid.
    internal static func isValid(_ board: [[Int]], row: Int, col: Int, num: Int) -> Bool {
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
}
