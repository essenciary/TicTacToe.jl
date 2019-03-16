using Pkg
pkg"activate ."

module TicTacToe

using PrettyTables
import Base: ==

export Board, Cell
export X, O, EMPTY
export A, B, C
export at!, at
export isover, new

export InvalidValueException, InvalidMoveException, InvalidCoordinatesException

const A = 'A'
const B = 'B'
const C = 'C'

const X = 'X'
const O = 'O'
const EMPTY = ' '

const labels = Dict{Char,Int}(A => 1, B => 2, C => 3)

abstract type TicTacToeException <: Exception end

struct InvalidValueException <: TicTacToeException
  value::Char
end

struct InvalidMoveException <: TicTacToeException
  msg::String
end

struct InvalidCoordinatesException <: TicTacToeException
  col::Char
  row::Int
end

struct Cell
  value::Char

  function Cell(v::Char)
    in(v, [X, O, ' ']) && return new(v)
    InvalidValueException(v) |> throw
  end
end
Cell() = Cell(EMPTY)

struct Board
  data::Matrix{Cell}
end
Board() = Board([ Cell() Cell() Cell();
                  Cell() Cell() Cell();
                  Cell() Cell() Cell()
                ])

Base.show(io::IO, cell::Cell) = print(io, cell.value)
Base.show(io::IO, board::Board) = pretty_table(board.data, [A, B, C], hlines = [1,2], show_row_number = true)

==(a::Cell, b::Cell) = a.value == b.value
Base.hash(cell::Cell) = hash(cell.value)

function at(board::Board, coords::Pair{Char,Int}) :: Cell
  if ! isvalidcolumn(coords[1]) || ! isvalidrow(coords[2])
    InvalidCoordinatesException(coords[1], coords[2]) |> throw
  end

  board.data[coords[2], labels[coords[1]]]
end

function at!(board::Board, value::Char, coords::Pair{Char,Int}) :: Board
  cell = Cell(value)

  current_value = at(board, coords)
  isemptycell(current_value) && isvalidvalue(cell) && isvalidsequence(board, cell) || InvalidMoveException("Cell already contains a value $current_value") |> throw

  board.data[coords[2], labels[coords[1]]] = cell

  board
end

function cells(board::Board) :: Base.Generator
  (c for c in board.data)
end

function rows(board::Board) :: Vector{Vector{Cell}}
  result = Vector{Vector{Cell}}()
  for x in 1:3
    push!(result, board.data[x,:])
  end

  result
end

function columns(board::Board) :: Vector{Vector{Cell}}
  result = Vector{Vector{Cell}}()
  for x in 1:3
    push!(result, board.data[:,x])
  end

  result
end

function diagonals(board::Board) :: Vector{Vector{Cell}}
  result = Vector{Vector{Cell}}()
  push!(result, Cell[board.data[1,1], board.data[2,2], board.data[3,3]])
  push!(result, Cell[board.data[1,3], board.data[2,2], board.data[3,1]])

  result
end

isemptycell(cell::Cell)::Bool = isempty(strip(string(cell.value)))
isvalidcolumn(value::Char)::Bool = in(value, keys(labels))
isvalidrow(value::Int)::Bool = 0 < value <= 3
isvalidvalue(cell::Cell)::Bool = in(cell.value, [X, O])

function isvalidsequence(board::Board, cell::Cell) :: Bool
  isemptycell(cell) && InvalidMoveException("Can only choose X or O") |> throw

  Xs = Os = 0
  for c in cells(board)
    if c.value == X
      Xs += 1
    elseif c.value == O
      Os += 1
    end
  end

  (Xs == Os && cell.value == X) || (Xs == Os + 1 && cell.value == O) ?
    true :
    throw(InvalidMoveException("Invalid move sequence $(cell.value)"))
end

function isover(board::Board) :: NamedTuple{(:status,:winner),Tuple{Bool,Char}}
  for c in TicTacToe.columns(board)
    c[1] == c[2] == c[3] && c[1] != Cell(EMPTY) && return (status = true, winner = c[1].value)
  end
  for r in TicTacToe.rows(board)
    r[1] == r[2] == r[3] && r[1] != Cell(EMPTY) && return (status = true, winner = r[1].value)
  end
  for d in TicTacToe.diagonals(board)
    d[1] == d[2] == d[3] && d[1] != Cell(EMPTY) && return (status = true, winner = d[1].value)
  end

  isempty(filter(TicTacToe.isemptycell, board.data)) && return (status = true, winner = EMPTY)

  (status = false, winner = EMPTY)
end

function new()
  upcoming_move = X
  board = Board()

  while ! isover(board).status
    println("Your move, $upcoming_move")
    show(board)

    move = readline() |> uppercase |> strip
    try
      at!(board, upcoming_move, Pair(move[1], parse(Int, move[2])))
      upcoming_move = upcoming_move == X ? O : X
    catch ex
      println(ex)
    end
  end

  println("Game over!")
  status = isover(board)
  if in(status.winner, [X, O])
    println("Congratulations $(status.winner)")
  else
    println("Draw")
  end

  show(board)
end

end
