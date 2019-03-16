using Test
include("../src/TicTacToe.jl")
using .TicTacToe

@testset "Board and cells" begin
  board = Board()
  @test at(board, A=>1).value == EMPTY

  at!(board, X, A=>1)
  @test at(board, A=>1).value == X

  at!(board, O, A=>2)
  @test at(board, A=>2).value == O

  @test_throws InvalidValueException at!(board, 'Z', A=>3)

  @test_throws InvalidCoordinatesException at(board, C=>4)
  @test_throws InvalidCoordinatesException at!(board, O, C=>4)

  @test_throws InvalidMoveException at!(board, X, A=>2)
  @test_throws InvalidMoveException at!(board, X, A=>1)
  @test_throws InvalidMoveException at!(board, ' ', A=>3)
end
