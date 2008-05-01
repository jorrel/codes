require 'rubygems'
require 'timeout'

$:.unshift File.join(File.dirname(__FILE__))
require 'core_ext'

module Sudoku
  class InvalidBoard < ArgumentError; end

  # a sudoku board
  # board = Sudoku::Board.new(two_dimentional_array)  # non-numbers will be treated as blanks
  # board.solution                                    # get the first solution found
  # board.solutions                                   # get all solutions found
  class Board
    attr_reader :cells

    def initialize(cells, options = {})
      assert_valid_board cells unless options[:validate] == false
      create cells
    end

    def solution
      solutions.first
    end

    def solutions
      Timeout.timeout(8) { find_solution }
    end

    def next_blank_cell
      cells.each_with_index do |row, i|
        row.each_with_index do |cell, j|
          return(block_given? ? yield(cell, i, j) : cell) if cell.blank?
        end
      end
      return nil # return nil of no next_blank_cell found
    end

    def possible_guesses(row, col)
      s = 3; guesses = (1..(s * s)).to_a
      guesses - (rows[row].map(&:value) + cols[col].map(&:value) + box_sets[(row / 3) * 3 + (col / 3)].map(&:value)).uniq
    end

    def inspect(blank = ' ')
      s = 3; rng = (0...s)
      "\n" + rng.collect { |r|
        cells[r*s...r*s+s].collect { |row|
          rng.collect { |c|
            row[c*s...c*s+s].collect { |cell| "[#{cell.blank? ? blank : cell.value}]" }.join
          }.join('  ') + "\n"
        }.join + "\n"
      }.join
    end

    # == should check the dump for equality
    def ==(another_board)
      dump == another_board.dump
    end

    # duplicate/clone this board
    def dup
      Sudoku::Board.new(dump)
    end

    def dump
      to_a(nil)
    end

    # return a 2 dimensional array of values
    def to_a(blank = '')
      cells.collect { |row| row.collect { |cell| "#{cell.value || blank}" } }
    end

    class << self
      # create an empty board
      def empty
        new (0...9).collect { (0...9).collect { '' } }
      end

      # new board bypassing validation (used mainly for testing)
      def unvalidated(array)
        new(array, :validate => false)
      end

      def valid?(array)
        conditions = [
          proc { |a| a.is_a?(Array) and a.all? { |b| b.is_a?(Array) } },    # 2 dimensional array
          proc { |a| a.map(&:size).all? { |size| size == a.size } },        # row = cols
          proc { |a| a.all? { |b| b.all? { |c| (0..9) === c.to_i } } },     # empty or 1 - 9
          proc { |a| a.all? { |b| b.no_dup_of_non_zero_nums? } },           # no same number in 1 row
          proc { |a| a.transpose.all? { |b| b.no_dup_of_non_zero_nums? } }, # no same number in 1 column
          proc { |cells|                                                    # no same number in 1 set
            s = 3; rng = (0...s)
            sets = [].tap { |sets|
              rng.each do |r|
                rng.each do |c|
                  sets << rng.collect { |r2| rng.collect { |c2| cells[s*r+r2][s*c+c2] } }.flatten
                end
              end
            }
            sets.all? { |set| set.no_dup_of_non_zero_nums? }
          }
        ]
        conditions.all? { |condition| condition.call(array) }
      end

      def valid_set?(cells)
        cells.map(&:value).compact.uniq_contents?
      end
    end

    private

      def assert_valid_board(cells)
        raise InvalidBoard, 'Invalid Sudoku Board' unless Sudoku::Board.valid?(cells)
      end

      def create(cells)
        @cells = cells.collect { |cell_row| cell_row.collect { |cell| Cell.new cell } }
      end

      def valid?
        [rows, cols, box_sets].all? { |sets| sets.all? { |set| Sudoku::Board.valid_set? set } }
      end

      def finished?
        filled? and valid?
      end

      def filled?
        cells.all? { |cell_row| cell_row.none?(&:blank?) }
      end

      def rows
        cells
      end

      def cols
        cells.transpose
      end

      # return an array of boxes (the small boxes)
      # ex: box1: {(0,0), (0,1), (0,2), (1,0), (1,1), (1,2), (2,0), (2,1), (2,2)}
      def box_sets
        s = 3             # size basic sudoku has size 3 (3 x 3 x 3 x 3)
        rng = (0...s)
        [].tap do |sets|
          rng.each do |r|
            rng.each do |c|
              sets << rng.collect { |r2| rng.collect { |c2| cells[s*r+r2][s*c+c2] } }.flatten
            end
          end
        end
      end

      def find_solution(matches_found = [])
        s = 3; _cells = @cells.dup
        next_blank_cell do |cell, i, j|
          possible_guesses(i, j).each do |guess|
            cell.set guess
            if finished?
              matches_found << self.dup
            else
              find_solution(matches_found)
            end
            cell.clear
          end
        end
        matches_found
      ensure
        @cells = _cells
      end

    public

      class Cell
        attr_reader :value, :fixed
        alias :fixed? :fixed

        def initialize(value, fixed = true)
          @fixed = fixed
          set value
        end

        def set(value)
          @value = Sudoku::Board::Cell.empty?(value) ? nil : value.to_i
        end

        def blank?
          value.blank?
        end

        def clear
          @value = nil
        end

        class << self
          def empty?(value)
            value.to_i <= 0
          end
        end
      end
  end
end
