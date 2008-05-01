#!/usr/bin/ruby
# == sudoku puzzle solver
# solves sudoku puzzles through brute-force approach
#
# == command line usage:
#   ruby sudoku_solver.rb <puzzle_file>
#   # or
#   ./sudoku_solver.rb <puzzle_file>
#   # or to profile:
#   ruby sudoku_solver.rb <puzzle_file> --profile

require 'sudoku'
require 'benchmark'

if not ARGV.empty? and File.exists?(ARGV[0])
  require 'action_view/helpers/text_helper'
  extend ActionView::Helpers::TextHelper

  profile = ARGV.include? '--profile'
  require 'profiler' if profile

  puzzle_location = ARGV[0]
  puzzle = File.read(puzzle_location).split(/\n+/).reject { |line| line =~ /^(\#|\s*$)/ }.map { |line| line.split(/\s+/) }
  board = Sudoku::Board.new(puzzle)
  puts "\nGiven puzzle: #{board.inspect}"

  solutions = []
  time_taken = Benchmark.realtime do
    puts "Profiling: this can take some time..." if profile
    Profiler__.start_profile if profile
    solutions = board.solutions
    Profiler__.stop_profile if profile
  end

  puts "\nFound #{pluralize solutions.size, 'solution'}.  Time taken: #{time_taken} seconds"
  for solution in solutions
    puts solution.inspect, "\n"
  end

  Profiler__.print_profile STDOUT if profile
else
  puts "Usage: ruby #{__FILE__} <puzzle_file> [--profile]"
end