#! /usr/bin/env shoes

$: << File.dirname(__FILE__)
require 'sudoku'

Shoes.app(:width => 520, :height => 550) {

  flow(:width => '100%', :margin => 10) {

    # display the board
    @cells = Sudoku::Board.empty.to_a
    s = 3; rng = (0...s)
    rng.each { |a|
      rng.each { |b|
        rng.each { |c|
          rng.each { |d|
            i, j = a * s + b, c * s + d
            stack(:width => 50) {
              @cells[i][j] = edit_line :width=> 50, :height => 50
            }
            stack(:width => 20) { } if d == 2 && j != 8
          }
        }
        stack(:width => '100%') { para '' } if b == 2 && a != 2
      }
    }

  }


  flow(:width => '80%') {

    # solve button
    button('Solve') {
      input = @cells.collect { |row| row.collect { |el| el.text } }

      begin
        board = Sudoku::Board.new(input)

        if solution = board.solution
          alert "Solution: \n\n#{solution.inspect}"
        else
          alert "No Solution: \n\n No solution possible was found.\n Please check your board."
        end

      rescue Timeout::Error
        alert("Computation Timeout: \n\n Sudoku Solver is taking a very long time.\n Please check your board.")

      rescue Sudoku::InvalidBoard
        alert("Invalid Board: \n\n The current board configuration is invalid.\n Please check your board.")
      end
    }

    button('Sample1') {
      load_puzzle('puzzle1')
    }

    button('Sample2') {
      load_puzzle('puzzle2')
    }

    button('Reset') {
      update_puzzle(Sudoku::Board.empty)
    }
  }

  def load_puzzle(file)
    puzzle_location = File.join(File.dirname(__FILE__), 'puzzles', file)
    puzzle = File.read(puzzle_location).split(/\n+/).reject { |line| line =~ /^(\#|\s*$)/ }.map { |line| line.split(/\s+/) }
    board = Sudoku::Board.new(puzzle)
    update_puzzle board
  end

  def update_puzzle(board)
    (rng = (0...9)).each { |i|
      rng.each { |j|
        @cells[i][j].text = board.cells[i][j].value.to_s
      }
    }
  end
}