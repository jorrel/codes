#! /usr/bin/env shoes

$: << File.dirname(__FILE__)
require 'sudoku'
require 'timeout'

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
        Timeout.timeout(8) {
          solution = board.solution
          puts "solution: \n#{solution.inspect}"
          alert "solution: \n#{solution.inspect}"
        }
      rescue Timeout::Error
        alert("Sudoku Solver is taking a very long time.\n Please check your board.")
      end
    }

#     button('Sample') {
#     }
  }
}