#! /usr/bin/env shoes

$: << File.dirname(__FILE__)
require 'sudoku'

Shoes.app(:width => 500, :height => 500) {

  flow(:width => '100%', :margin => 10) {

    # display the board
    @cells = (0...9).collect { (0...9).collect { '' } }  # raw 2 dimensional array
    s = 3; rng = (0...s)
    rng.each { |a|
      rng.each { |b|
        rng.each { |c|
          rng.each { |d|
            i, j = a * s + b, c * s + d
            stack(:width => 50) {
              @cells[i][j] = edit_line :width=> 50, :height => 50
            }
          }
        }
      }
    }

  }


  flow(:width => '80%') {

    # solve button
    button('Solve') {
      input = @cells.collect { |row| row.collect { |el| el.text } }

      board = Sudoku::Board.new(input)
      puts "given board: \n#{board.inspect}\n"

      begin
        solution = board.solution
        puts "solution: \n#{solution.inspect}"
        alert "solution: \n#{solution.inspect}"
      rescue Timeout::Error
        alert("Sudoku Solver is taking a very long time.\n Please check your board.")
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