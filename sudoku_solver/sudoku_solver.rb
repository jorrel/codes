#! /usr/bin/env shoes

# because, somehow, shoes changes __FILE__
# install_dir = File.join(* File.expand_path(__FILE__).split('/')[0..-2])
#
# puts "require #{File.join(install_dir, 'sudoku.rb').inspect}"
# require File.join(install_dir, 'sudoku.rb')

require File.join(File.dirname(__FILE__), 'sudoku.rb')

Shoes.app(:width => 500, :height => 500) {

  cells = (0...9).collect { (0...9).collect { '' }}

#   puts cells.inspect

#   (0...9).each { |a|
#     puts a
#     (0...9).each { |b|
#       puts b
#       puts "(#{a}, #{b})"
#       puts "cells[#{a}][#{b}] = #{(a * 10) + b}"
#       cells[a][b] = (a * 10) + b #"(#{a}, #{b})"
#     }
#   }

#   puts cells.inspect

  board = Sudoku::Board.new(cells)

#   puts board.inspect

  flow(:width => '100%', :margin => 10) {

    s = 3; rng = (0...s)
    rng.each { |a|
      rng.each { |b|
        rng.each { |c|
          rng.each { |d|
            i, j = a * s + b, c * s + d
            stack(:width => 50) {
              cells[i][j] = edit_line :width=> 50, :height => 50
            }
          }
        }
      }
    }

  }


  flow(:width => '80%') {
    button('Solve') {
      input = cells.collect { |row| row.collect { |el| el.text } }

      board = Sudoku::Board.new(input)
      puts "given board: \n#{board.inspect}\n"

      solution = board.solution
      puts "solution: \n#{solution.inspect}"
      alert "solution: \n#{solution.inspect}"
    }
  }
}