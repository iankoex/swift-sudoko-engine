import Testing
@testable import SudukoEngine

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    let generator = SudokuGenerator()

        do {
            // Generates a Sudoku puzzle of difficulty level: medium
            let puzzle = try await generator.generateSudoku(difficulty: .medium)
            print("Generated Sudoku Puzzle:\n")
            print(puzzle)
        } catch {
            print("Error generating Sudoku: \(error)")
        }
    
}
