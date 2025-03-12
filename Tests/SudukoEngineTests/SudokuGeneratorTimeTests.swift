////
////  SudokuGeneratorTimeTests.swift
////  swift-suduko-engine
////
////  Created by ian on 12/03/2025.
////
//
//import Testing
//@testable import SudukoEngine
//
//@Suite("Sudoku Generator Time Taken")
//class SudokuGeneratorTimeTests {
//
//    @Test("Test Time Taken to Generate a Valid Sudoku with Easy Difficulty")
//    func testTimeTakenToGenerateAnEasySudoku() async throws {
//        do {
//            let duration = try await ContinuousClock().measure {
//                for _ in 0..<100 {
//                    _ = try await SudokuGenerator.generate(difficulty: .easy)
//                }
//            }
//            #expect(duration < Duration.seconds(1.2))
//        } catch {
//            print("Error generating Sudoku: \(error)")
//        }
//    }
//
//    @Test("Test Time Taken to Generate a Valid Sudoku with Medium Difficulty")
//    func testTimeTakenToGenerateAnMediumSudoku() async throws {
//        do {
//            let duration = try await ContinuousClock().measure {
//                for _ in 0..<100 {
//                    _ = try await SudokuGenerator.generate(difficulty: .medium)
//                }
//            }
//            #expect(duration < Duration.seconds(2.3))
//        } catch {
//            print("Error generating Sudoku: \(error)")
//        }
//    }
//
//    @Test("Test Time Taken to Generate a Valid Sudoku with Hard Difficulty")
//    func testTimeTakenToGenerateAnHardSudoku() async throws {
//        do {
//            let duration = try await ContinuousClock().measure {
//                for _ in 0..<100 {
//                    _ = try await SudokuGenerator.generate(difficulty: .hard)
//                }
//            }
//            #expect(duration < Duration.seconds(4.3))
//        } catch {
//            print("Error generating Sudoku: \(error)")
//        }
//    }
//}
