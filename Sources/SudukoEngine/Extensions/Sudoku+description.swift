//
//  File.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//

#if canImport(Foundation)
import Foundation

public extension Sudoku {
    /// A custom string representation of the complete Sudoku puzzle.
    ///
    /// This computed property organizes and prints all cells of the puzzle in a human-readable,
    /// row-by-row format. Each cell is represented using its coordinate and value in the format "A1:0".
    ///
    /// Example output:
    ///   0 0 0 0 0 0 0 0 0
    ///   0 0 0 0 0 0 0 0 0
    ///   ...
    /// - Returns: A string that visually represents the Sudoku puzzle by rows.
    var description: String {
        // Create a dictionary to map cell coordinates (e.g., "A1") to their values.
        var cellsByCoordinate: [String: Int] = [:]

        // Collect all cells from all grids in the Sudoku puzzle.
        for sudokuGrid in grid {
            for cell in sudokuGrid.cells {
                // Each coordinate is constructed by concatenating the cell's column and row.
                let coordinate = "\(cell.column)\(cell.row)"
                cellsByCoordinate[coordinate] = cell.value
            }
        }

        // Define the order of columns (from "A" to "I") and rows (from "1" to "9") for formatting.
        let columns = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
        let rows = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

        // Build the puzzle's string representation row by row.
        var result = ""
        for row in rows {
            var rowString = ""
            for column in columns {
                let coordinate = "\(column)\(row)"
                // Retrieve the value for the current coordinate or use 0 if missing.
                let value = cellsByCoordinate[coordinate] ?? 0
                rowString += "\(value) "
            }
            // Add the rowString to result, trimming extra spaces, and then append a newline.
            result += rowString.trimmingCharacters(in: .whitespaces) + "\n"
        }

        // Return the final string after trimming any trailing newline characters.
        return result.trimmingCharacters(in: .newlines)
    }
}

extension Sudoku.SudokuGrid {
    /// A custom string representation of the Sudoku grid.
    ///
    /// This computed property returns a string that begins with the grid’s position, followed by a
    /// list of all individual cells (using each cell's custom description) separated by a space.
    ///
    /// Example output:
    ///   "Grid 1: A1:0 B1:0 C1:0 ... "
    public var description: String {
        var result = "Grid \(position): "
        for cell in cells {
            // Append each cell's description (e.g., "A1:0") to the result.
            result += "\(cell.description) "
        }
        // Remove any trailing whitespace.
        return result.trimmingCharacters(in: .whitespaces)
    }
}

extension Sudoku.SudokuGrid.Cell {
    /// A custom string representation of the cell.
    ///
    /// The description is formatted as "A1:0", which includes the cell's column,
    /// row, and its current value.
    public var description: String {
        return "\(column)\(row):\(value)"
    }
}
#endif
