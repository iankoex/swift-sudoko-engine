//
//  SudokuGeneratorTests.swift
//  swift-suduko-engine
//
//  Created by ian on 12/03/2025.
//

import Testing
@testable import SudukoEngine
import Foundation

@Suite("Sudoku Generator")
class SudokuGeneratorTests {

    // MARK: - 1. Verify Unique Solution for Each Difficulty

    @Test("Generated easy Sudoku has unique solution")
    func testEasySudokuHasUniqueSolution() async throws {
        // Generate a Sudoku using the easy difficulty.
        let generated = try await SudokuGenerator.generate(difficulty: .easy)

        // Retrieve the puzzle board representation.
        var board = generated.puzzle.boardRepresentation

        // Count the number of solutions.
        let solutions = SudokuGenerator.countSolutions(for: &board, limit: 2)

        // Expect exactly one solution.
        #expect(solutions == 1)
    }

    @Test("Generated medium Sudoku has unique solution")
    func testMediumSudokuHasUniqueSolution() async throws {
        // Generate a Sudoku using the medium difficulty.
        let generated = try await SudokuGenerator.generate(difficulty: .medium)

        // Retrieve the puzzle board representation.
        var board = generated.puzzle.boardRepresentation

        // Count the number of solutions.
        let solutions = SudokuGenerator.countSolutions(for: &board, limit: 2)

        // Expect exactly one solution.
        #expect(solutions == 1)
    }

    @Test("Generated hard Sudoku has unique solution")
    func testHardSudokuHasUniqueSolution() async throws {
        // Generate a Sudoku using the hard difficulty.
        let generated = try await SudokuGenerator.generate(difficulty: .hard)

        // Retrieve the puzzle board representation.
        var board = generated.puzzle.boardRepresentation

        // Count the number of solutions.
        let solutions = SudokuGenerator.countSolutions(for: &board, limit: 2)

        // Expect exactly one solution.
        #expect(solutions == 1)
    }

    @Test("Generated solved board is fully valid according to Sudoku rules")
    func testSolvedBoardIntegrity() async throws {
        let generated = try await SudokuGenerator.generate(difficulty: .medium)
        let board = generated.solved.boardRepresentation

        // Check rows for uniqueness.
        for row in 0..<9 {
            let rowValues = board[row]
            let uniqueValues = Set(rowValues)
            #expect(uniqueValues.count == 9)
        }

        // Check columns for uniqueness.
        for col in 0..<9 {
            var columnValues = [Int]()
            for row in 0..<9 {
                columnValues.append(board[row][col])
            }
            #expect(Set(columnValues).count == 9)
        }

        // Check each 3x3 subgrid.
        for blockRow in stride(from: 0, to: 9, by: 3) {
            for blockCol in stride(from: 0, to: 9, by: 3) {
                var blockValues = [Int]()
                for row in blockRow..<blockRow + 3 {
                    for col in blockCol..<blockCol + 3 {
                        blockValues.append(board[row][col])
                    }
                }
                #expect(Set(blockValues).count == 9)
            }
        }
    }

    @Test("Generated Puzzle preserves symmetry when removing cells")
    func testPuzzleSymmetry() async throws {
        let generated = try await SudokuGenerator.generate(difficulty: .medium)
        let board = generated.puzzle.boardRepresentation

        // For symmetry, assume that if a cell at (row, col) is empty,
        // then the cell at the symmetric position (8 - row, 8 - col) should also be empty.
        for row in 0..<9 {
            for col in 0..<9 {
                let symRow = 8 - row
                let symCol = 8 - col
                if board[row][col] == 0 {
                    #expect(board[symRow][symCol] == 0)
                }
            }
        }
    }

    @Test("Generated solved Sudoku board is valid")
    func testSolvedBoardValidity() async throws {
        let generated = try await SudokuGenerator.generate(difficulty: .medium)
        let board = generated.solved.boardRepresentation

        // Check each row
        for row in 0..<9 {
            let rowValues = board[row]
            let uniqueValues = Set(rowValues)
            #expect(uniqueValues.count == 9)
        }

        // Check each column
        for col in 0..<9 {
            var colValues = [Int]()
            for row in 0..<9 {
                colValues.append(board[row][col])
            }
            let uniqueValues = Set(colValues)
            #expect(uniqueValues.count == 9)
        }

        // Check each 3x3 subgrid
        for startRow in stride(from: 0, to: 9, by: 3) {
            for startCol in stride(from: 0, to: 9, by: 3) {
                var blockValues = [Int]()
                for row in startRow..<startRow+3 {
                    for col in startCol..<startCol+3 {
                        blockValues.append(board[row][col])
                    }
                }
                let uniqueValues = Set(blockValues)
                #expect(uniqueValues.count == 9)
            }
        }
    }

    @Test("Easy puzzles leave more givens than hard puzzles")
    func testEasyVsHardGivens() async throws {
        let easyGenerated = try await SudokuGenerator.generate(difficulty: .easy)
        let hardGenerated = try await SudokuGenerator.generate(difficulty: .hard)

        let easyGivens = easyGenerated.puzzle.boardRepresentation.flatMap { $0 }.filter { $0 != 0 }.count
        let hardGivens = hardGenerated.puzzle.boardRepresentation.flatMap { $0 }.filter { $0 != 0 }.count

        // Expect that easy puzzles have significantly more numbers already provided.
        #expect(easyGivens > hardGivens)
    }

    @Test("Generated puzzle cells are not over-removed for each difficulty")
    func testGivensAreWithinExpectedRange() async throws {
        let difficulties: [Sudoku.Difficulty] = [.easy, .medium, .hard]
        for diff in difficulties {
            let generated = try await SudokuGenerator.generate(difficulty: diff)
            let board = generated.puzzle.boardRepresentation
            let givens = board.flatMap { $0 }.filter { $0 != 0 }.count

            // Expected givens count depends on removalCount; these ranges are illustrative:
            // An easy puzzle should have closer to 81 - easy.removalCount givens.
            let expected = 81 - diff.removalCount
            // Allow a tolerance of ±5 given possible uniqueness constraints.
            #expect(abs(givens - expected) <= 5)
        }
    }

    @Test("Puzzle difficulty impacts number of removed cells")
    func testRemovalCountMatchesDifficulty() async throws {
        // Here we assume the removalCount is indicative
        // of how many cells are intended to be removed.
        // Since removal is done in pairs and may not
        // exactly hit the number if uniqueness is preserved,
        // we check that the number of filled cells (givens)
        // is within an expected range.

        let generated = try await SudokuGenerator.generate(difficulty: .hard)
        let board = generated.puzzle.boardRepresentation

        // Count the number of givens (non-zero entries)
        let numGivens = board.flatMap { $0 }.filter { $0 != 0 }.count

        // For a hard puzzle, we might expect fewer givens.
        // For example, with removalCount = 50 (approximately),
        // we would theoretically have 81 - 50 = 31 givens.
        // Allow some tolerance due to symmetry constraints.
        let lowerBound = 25
        let upperBound = 35
        #expect(numGivens >= lowerBound && numGivens <= upperBound)
    }

    @Test("Generate solved Sudoku directly produces a valid board")
    func testGenerateSolvedSudokuDirectly() async throws {
        let solvedSudoku = try await SudokuGenerator.generateSolvedSudoku()
        let board = solvedSudoku.boardRepresentation

        // Validate row uniqueness.
        for row in 0..<9 {
            let rowValues = board[row]
            #expect(Set(rowValues).count == 9)
        }
        // Validate column uniqueness.
        for col in 0..<9 {
            var columnValues = [Int]()
            for row in 0..<9 {
                columnValues.append(board[row][col])
            }
            #expect(Set(columnValues).count == 9)
        }
    }

    @Test("Multiple generated puzzles for the same difficulty are not identical")
    func testMultiplePuzzlesAreDifferent() async throws {
        let firstGenerated = try await SudokuGenerator.generate(difficulty: .medium)
        let secondGenerated = try await SudokuGenerator.generate(difficulty: .medium)

        // Convert boards to a flattened representation for easy comparison
        let firstPuzzle = firstGenerated.puzzle.boardRepresentation.flatMap { $0 }
        let secondPuzzle = secondGenerated.puzzle.boardRepresentation.flatMap { $0 }

        // They might be different in at least one position.
        #expect(firstPuzzle != secondPuzzle)
    }

    @Test("Each cell has valid row and column identifiers")
    func testCellsHaveValidIdentifiers() async throws {
        let generated = try await SudokuGenerator.generate(difficulty: .medium)
        // Loop through each grid and each cell and verify that the identifiers are non-empty.
        for grid in generated.solved.grid {
            for cell in grid.cells {
                #expect(!cell.row.isEmpty)
                #expect(!cell.column.isEmpty)
                // Optionally, verify that row is a number between "1" and "9" and column between "A" and "I"
                #expect(Int(cell.row) != nil)
                let validColumns = (0..<9).map { String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32($0))!) }
                #expect(validColumns.contains(cell.column))
            }
        }
    }
}
