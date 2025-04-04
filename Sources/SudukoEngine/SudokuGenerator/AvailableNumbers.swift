//
//  File.swift
//  swift-suduko-engine
//
//  Created by ian on 28/03/2025.
//

import Foundation

extension SudokuGenerator {
    /// Returns the list of available numbers for user input.
    ///
    /// This method first filters out cells that have already been filled in the puzzle,
    /// and then it retrieves the corresponding solution cells using their unique identifiers.
    /// Finally, it iterates through the numbers 1 to 9, checking if at least one filtered cell
    /// in the solution has that number.
    ///
    /// - Parameters:
    ///   - puzzle: The Sudoku puzzle representing the user’s current state.
    ///   - solution: The complete solution Sudoku puzzle.
    /// - Returns: An array of integers representing the numbers available for user input.
    public static func getAvailableNumbers(from puzzle: Sudoku, using solution: Sudoku) -> [Int] {
        // Filter to get only those cells in the puzzle that are empty.
        let emptyPuzzleCells = puzzle.allCells.filter { $0.value == 0 }

        // Create a lookup dictionary for solution cells by their unique id.
        // This makes it faster to get the corresponding solution cell.
        let solutionDict = Dictionary(uniqueKeysWithValues: solution.allCells.map { ($0.id, $0) })

        // Using the empty cells' ids, gather the corresponding solution cells.
        var filteredSolutionCells = [Sudoku.SudokuGrid.Cell]()
        for cell in emptyPuzzleCells {
            if let solutionCell = solutionDict[cell.id] {
                filteredSolutionCells.append(solutionCell)
            }
        }

        // Now, determine available numbers from 1 to 9 by checking the filtered solution cells.
        var availableNumbers: [Int] = []
        for number in 1...9 {
            // If any of the corresponding solution cells has the current number,
            // mark this number as available. Once found, no need to check further.
            if filteredSolutionCells.first(where: { $0.value == number }) != nil {
                availableNumbers.append(number)
            }
        }

        return availableNumbers
    }
}
