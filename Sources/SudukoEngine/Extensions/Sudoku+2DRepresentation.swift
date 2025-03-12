//
//  Sudoku+2DRepresentation.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//

// Helper extension to convert Sudoku to a 2D board representation.
extension Sudoku {
    /// Converts the Sudoku structure to a 9x9 2D array of Int.
    var boardRepresentation: [[Int]] {
        var board = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
        for row in 0..<9 {
            for col in 0..<9 {
                let columnLetter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(col))!)
                let rowLetter = String(row + 1)
                // Find the cell containing this row and column in any grid.
                // This assumes a flat search through the grids.
                if let cell = self.grid.flatMap({ $0.cells }).first(where: { $0.column == columnLetter && $0.row == rowLetter }) {
                    board[row][col] = cell.value
                }
            }
        }
        return board
    }
}
