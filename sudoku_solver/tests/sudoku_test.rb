require File.dirname(__FILE__) + '/../sudoku'
require 'test/unit'

VALID_BOARD = [
  %w(_ _ 7  _ _ 6  3 _ _),
  %w(_ 8 _  2 9 _  _ 4 _),
  %w(5 _ 4  3 _ _  1 _ 2),

  %w(8 _ _  _ 6 _  7 9 _),
  %w(_ 3 _  8 _ 7  _ 1 _),
  %w(_ 6 5  _ 1 _  _ _ 4),

  %w(4 _ 9  _ _ 5  2 _ 6),
  %w(_ 7 _  _ 3 4  _ 5 _),
  %w(_ _ 6  1 _ _  4 _ _),
]
VALID_ANSWER = [
  %w(1 2 7  4 5 6  3 8 9),
  %w(6 8 3  2 9 1  5 4 7),
  %w(5 9 4  3 7 8  1 6 2),

  %w(8 4 1  5 6 2  7 9 3),
  %w(9 3 2  8 4 7  6 1 5),
  %w(7 6 5  9 1 3  8 2 4),

  %w(4 1 9  7 8 5  2 3 6),
  %w(2 7 8  6 3 4  9 5 1),
  %w(3 5 6  1 2 9  4 7 8),
]
INVALID_ANSWER = [
  %w(1 1 7  4 5 6  3 8 9),        # 1, 1
  %w(6 8 3  2 9 1  5 4 7),
  %w(5 9 4  3 7 8  1 6 2),

  %w(8 4 1  5 6 2  7 9 3),
  %w(9 3 2  8 4 7  6 1 5),
  %w(7 6 5  9 1 3  8 2 4),

  %w(4 1 9  7 8 5  2 3 6),
  %w(2 7 8  6 3 4  9 5 1),
  %w(3 5 6  1 2 9  4 7 8),
]

class SudokuBoardTest < Test::Unit::TestCase
  def setup
    @board = Sudoku::Board.new(VALID_BOARD)
  end

  def test_board_validation
    assert Sudoku::Board.valid?(VALID_BOARD)
    assert Sudoku::Board.valid?(VALID_ANSWER)
    assert !Sudoku::Board.valid?(VALID_BOARD[0..-2])

    # check no duplicate within the same row
    board = VALID_BOARD.map(&:dup)
    board[0][1] = board[0][7] = 3
    assert !Sudoku::Board.valid?(board)

    # check no duplicate within the same column
    board = VALID_BOARD.map(&:dup)
    board[0][0] = board[5][0] = 2
    assert !Sudoku::Board.valid?(board)

    # check no duplicate within the same box set
    board = VALID_BOARD.map(&:dup)
    board[0][0] = board[2][1] = 9
    assert !Sudoku::Board.valid?(board)
  end

  def test_board_converts_cells
    assert_instance_of Array, @board.cells
    @board.cells.each do |cell_row|
      assert_instance_of Array, cell_row
      assert cell_row.all? { |cell| cell.is_a? Sudoku::Board::Cell }
    end
  end

  def test_filled
    assert Sudoku::Board.new(VALID_ANSWER).send(:filled?)
    assert !Sudoku::Board.new(VALID_BOARD).send(:filled?)
    assert Sudoku::Board.unvalidated(INVALID_ANSWER).send(:filled?), 'should still be filled even if invalid'
  end

  def test_valid
    assert Sudoku::Board.new(VALID_ANSWER).send(:valid?)
    assert Sudoku::Board.new(VALID_BOARD).send(:valid?), 'should be valid even if not finished'
    assert !Sudoku::Board.unvalidated(INVALID_ANSWER).send(:valid?)
  end

  def test_finished
    assert Sudoku::Board.new(VALID_ANSWER).send(:finished?)
    assert !Sudoku::Board.new(VALID_BOARD).send(:finished?)
    assert !Sudoku::Board.unvalidated(INVALID_ANSWER).send(:finished?)
  end

  def test_valid_set
    valid_set = %w(1 2 3 4 5 6 7 8 9).map { |cell| Sudoku::Board::Cell.new cell }
    assert Sudoku::Board.valid_set?(valid_set)

    invalid_set = %w(1 2 1 4 5 6 7 8 9).map { |cell| Sudoku::Board::Cell.new cell }
    assert !Sudoku::Board.valid_set?(invalid_set)
  end

  def test_box_sets
    board = Sudoku::Board.new(VALID_ANSWER)
    box_sets = board.send(:box_sets)
    assert_equal [1,2,7,6,8,3,5,9,4], box_sets[0].map(&:value)
    assert_equal [4,5,6,2,9,1,3,7,8], box_sets[1].map(&:value)
    assert_equal [3,8,9,5,4,7,1,6,2], box_sets[2].map(&:value)
    assert_equal [8,4,1,9,3,2,7,6,5], box_sets[3].map(&:value)
    assert_equal [5,6,2,8,4,7,9,1,3], box_sets[4].map(&:value)
    assert_equal [7,9,3,6,1,5,8,2,4], box_sets[5].map(&:value)
    assert_equal [4,1,9,2,7,8,3,5,6], box_sets[6].map(&:value)
    assert_equal [7,8,5,6,3,4,1,2,9], box_sets[7].map(&:value)
    assert_equal [2,3,6,9,5,1,4,7,8], box_sets[8].map(&:value)
  end

  def test_to_a
    assert_equal VALID_ANSWER, Sudoku::Board.new(VALID_ANSWER).to_a
    assert_equal VALID_BOARD, Sudoku::Board.new(VALID_BOARD).to_a('_'), "should express blanks as '_'"
    assert_equal INVALID_ANSWER, Sudoku::Board.unvalidated(INVALID_ANSWER).to_a
  end

  def test_next_blank_cell
    assert_equal @board.cells[0][0], @board.next_blank_cell
    @board.cells[0][0].set(1)
    assert_equal @board.cells[0][1], @board.next_blank_cell
    @board.cells[0][1].set(2)
    assert_equal @board.cells[0][3], @board.next_blank_cell

    board = Sudoku::Board.new(VALID_ANSWER)
    assert_equal nil, board.next_blank_cell, 'should return nil if no more blank cell'
    board.cells[4][5].clear
    assert_equal board.cells[4][5], board.next_blank_cell, 'cleared cell should be the next blank'
  end

  def test_possible_guesses
    assert_equal [1,2,9], @board.possible_guesses(0,0)
    assert_equal [2,4,5], @board.possible_guesses(4,4)
    assert_equal [3,7,8,9], @board.possible_guesses(8,8)
  end

  def test_solutions
    solution = @board.solution
    solutions = @board.solutions
    assert_equal 1, solutions.size
    assert_equal solution, solutions.first
    assert_instance_of Sudoku::Board, solution
    assert solution.send(:valid?)
    assert_equal VALID_ANSWER, solution.to_a('_')
  end
end

class SudokuBoardCellTest < Test::Unit::TestCase
  def test_fixed_cell
    assert Sudoku::Board::Cell.new(1, true).fixed?
    assert Sudoku::Board::Cell.new(2).fixed?, 'should set fixed to true by default'
    assert !Sudoku::Board::Cell.new(3, false).fixed?
  end

  def test_blank_cell
    assert !Sudoku::Board::Cell.new(4).blank?
    assert Sudoku::Board::Cell.new('_').blank?
    assert Sudoku::Board::Cell.new('[]').blank?
    assert Sudoku::Board::Cell.new(0).blank?, 'zero is blank'
    assert Sudoku::Board::Cell.new('0').blank?, 'zero is blank'
  end

  def test_value
    assert_equal 5, Sudoku::Board::Cell.new(5).value
    assert_equal 6, Sudoku::Board::Cell.new('6').value, 'should integerize values'
    assert_equal nil, Sudoku::Board::Cell.new('_').value, 'blanks have a nil value'
  end

  def test_set
    cell = Sudoku::Board::Cell.new('_')
    cell.set(7)
    assert_equal 7, cell.value
  end

  def test_clear
    cell = Sudoku::Board::Cell.new(7)
    cell.clear
    assert_equal nil, cell.value
    assert cell.blank?
  end
end