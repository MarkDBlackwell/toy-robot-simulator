=begin
=end
=begin
Author: Mark D. Blackwell
Dates:
November 1, 2013 - create

Based on:
A Test Ruby Program
From Locomote (http://www.locomote.com), an Australian based development company.

Ref:
http://rubylearning.com/blog/2011/07/28/how-do-i-test-my-code-with-minitest/
=end

require 'minitest/autorun'

module ToyRobot
  class TestRun < MiniTest::Unit::TestCase
    def setup() @runner = Run.new end

    def test_letter_a
      input = <<END_OF_INPUT
PLACE
REPORT
END_OF_INPUT
      s = input.each_line.map{|e| @runner.feed_line e}.join ''
      expect = 'At [0, 0], facing EAST'
      assert_equal expect, s
    end

    def test_null_input
      s = @runner.feed_line
      assert_equal '', s
    end

    def test_startup_message() assert_match /Welcome/, @runner.startup_message end

    def test_tokenizer
      expect = %w[ a b ]
      comma = @runner.tokenize 'a,b'
      assert_equal expect, comma
      space = @runner.tokenize 'a b'
      assert_equal expect, space
    end
  end

  class TestRobot < MiniTest::Unit::TestCase
    def setup() @robot = Robot.new end

    def test_can_move
      @robot.make_valid
      start_location = [2, 2]
      %w[  EAST   NORTH    WEST   SOUTH  ].zip(
        [ [3, 2], [2, 3], [1, 2], [2, 1] ]).each do |direction,location|
        @robot.reposition start_location
        @robot.orient direction
        @robot.move
        assert_equal direction, @robot.direction
        assert_equal location,  @robot.position
      end
    end

    def test_can_move_east
      @robot.make_valid
      @robot.move
      assert_equal 'EAST', @robot.direction
      assert_equal [1, 0], @robot.position
    end

    def test_can_orient
      sample = 'any direction'
      @robot.orient sample
      assert_equal sample, @robot.direction
    end

    def test_can_place
      direction, position = 'any direction', [-1, -1]
      @robot.place position, direction
      assert_equal direction, @robot.direction
      assert_equal position,  @robot.position
    end

    def test_can_reposition
      sample = [-1, -1]
      @robot.reposition sample
      assert_equal sample, @robot.position
    end

    def test_can_revert_direction
      direction = 'NORTH'
      @robot.make_valid
      @robot.orient direction
      assert_equal direction, @robot.direction
      @robot.revert
      assert_equal 'EAST', @robot.direction
    end

    def test_can_revert_position
      position = [1, 1]
      @robot.make_valid
      @robot.reposition position
      assert_equal position, @robot.position
      @robot.revert
      assert_equal [0, 0], @robot.position
    end

    def test_can_turn_left
      @robot.make_valid
      %w[ NORTH WEST SOUTH EAST ].each do |e|
        @robot.turn_left
        assert_equal e, @robot.direction
      end
    end

    def test_can_turn_right
      @robot.make_valid
      %w[ SOUTH WEST NORTH EAST ].each do |e|
        @robot.turn_right
        assert_equal e, @robot.direction
      end
    end

    def test_invalid_after_orienting_in_bad_direction
      @robot.make_valid
      bad_direction = 'bad'
      @robot.orient bad_direction
      assert ! @robot.valid?
    end

    def test_invalid_after_repositioning_with_bad_coordinates
      @robot.make_valid
      bad_coordinates = [-1, 5]
      bad_coordinates.zip(bad_coordinates).each do |x,y|
        @robot.reposition [x, y]
        assert ! @robot.valid?, "(x,y) was (#{x},#{y})"
      end
    end

    def test_invalid_before_the_first_place_command() assert ! @robot.valid? end

    def test_valid_after_orienting_in_good_direction
      @robot.make_valid
      Table::DIRECTIONS.each do |e|
        @robot.orient e
        assert @robot.valid?
      end
    end

    def test_valid_after_repositioning_with_good_coordinates
      @robot.make_valid
      good_coordinates = [0, 0]
      @robot.reposition good_coordinates
      assert @robot.valid?
    end

    def test_valid_after_the_first_place_command() @robot.place; assert @robot.valid? end
  end

  class TestSafeRobot < MiniTest::Unit::TestCase
    def setup() @robot = SafeRobot.new end

    def test_after_valid_place_can_move
      @robot.place
      s = @robot.move
#puts s
      assert_equal '', s
      assert_equal 'EAST', @robot.direction
      assert_equal [1, 0], @robot.position
    end

    def test_after_valid_place_can_turn_left
      @robot.place
      s = @robot.turn_left
#puts s
      assert_equal '', s
      assert_equal 'NORTH', @robot.direction
      assert_equal [0, 0],  @robot.position
    end

    def test_after_valid_place_can_turn_right
      @robot.place
      s = @robot.turn_right
#puts s
      assert_equal '', s
      assert_equal 'SOUTH', @robot.direction
      assert_equal [0, 0],  @robot.position
    end

    def test_before_valid_place_discards_move
      s = @robot.move
#puts s
      assert_equal 'Must start with a valid Place command', s
      assert_equal 'bad',    @robot.direction
      assert_equal [-1, -1], @robot.position
    end

    def test_before_valid_place_discards_turn_left
      s = @robot.turn_left
#puts s
      assert_equal 'Must start with a valid Place command', s
      assert_equal 'bad',    @robot.direction
      assert_equal [-1, -1], @robot.position
    end

    def test_before_valid_place_discards_turn_right
      s = @robot.turn_right
#puts s
      assert_equal 'Must start with a valid Place command', s
      assert_equal 'bad',    @robot.direction
      assert_equal [-1, -1], @robot.position
    end

    def test_invalid_move_after_right
# Covers a bug which emerged in user testing.
      @robot.place
      @robot.turn_right
      assert_equal 'SOUTH', @robot.direction
      @robot.move
#print '@robot.report='; p @robot.report
      assert_equal 'SOUTH', @robot.direction
    end

    def test_report_from_custom_position
      @robot.place [2, 3], 'WEST'
      s = @robot.report
#puts s
      assert_equal 'At [2, 3], facing WEST', s
    end

    def test_report_from_default_position
      @robot.place
      s = @robot.report
#puts s
      assert_equal 'At [0, 0], facing EAST', s
    end
  end

  class TestTable < MiniTest::Unit::TestCase
    def setup() @table = Table.new end

    def test_compass_directions_must_be_in_the_correct_order
      correct_order = %w[ EAST NORTH WEST SOUTH ]
      assert_equal correct_order, Table::DIRECTIONS
    end

    def test_must_have_compass_directions() assert Table::DIRECTIONS end

    def test_must_have_four_compass_directions() assert_equal 4, Table::DIRECTIONS_LENGTH end
  end
end

#--------------

module ToyRobot
  class Robot
    attr_reader :direction
    attr_reader :position

    def initialize
      bad_dimension_example = Table::OKAY_DIMENSION.begin - 1
      @position = Array.new(2){bad_dimension_example}
      @direction = 'bad'
    end

    def make_valid() reposition [0, 0]; orient 'EAST' end

    def move
      raise unless Table::DIRECTIONS.include? @direction
      which     =  Table::DIRECTIONS.index    @direction
      increment =  Table::DIRECTIONS_INCREMENT.at which
      new_position = @position.each_index.map{|i| (@position.at i) + (increment.at i)}
      reposition new_position
    end

    def orient(direction)
      @save_direction, @direction = @direction, direction
      @save_position = @position
    end

    def place(position=[0, 0], direction='EAST')
      @save_position,  @position  = @position,  position
      @save_direction, @direction = @direction, direction
    end

    def reposition(position)
      @save_position, @position = @position, position
      @save_direction = @direction
    end

    def revert() @direction, @position = @save_direction, @save_position end

    def turn(increment)
      raise unless [-1, 1].include? increment
      which = Table::DIRECTIONS.index @direction
      sum   = Table::DIRECTIONS_LENGTH + which + increment
      orient  Table::DIRECTIONS.at sum %
              Table::DIRECTIONS_LENGTH
    end

    def turn_left () turn  1 end
    def turn_right() turn -1 end

    def valid?
      both_within = @position.all?{|e| Table::OKAY_DIMENSION.include? e}
      direction_good = Table::DIRECTIONS.include? @direction
      both_within && direction_good
    end
  end

  class SafeRobot < Robot
    def check_after() valid? ? '' : (revert; 'Invalid') end

    def guard() valid? ? '' : 'Must start with a valid Place command' end

    def move
      s = guard
      (super; s = check_after) if s.empty?
      s
    end

    def place(location=[0, 0], direction='EAST') super; check_after end

    def report() "At #{position}, facing #{direction}" end

    def turn_left
      s = guard
      (super; s = check_after) if s.empty?
      s
    end

    def turn_right
      s = guard
      (super; s = check_after) if s.empty?
      s
    end
  end

  class Table
    DIRECTIONS =         %w[  EAST   NORTH     WEST    SOUTH  ]
    DIRECTIONS_INCREMENT = [ [1, 0], [0, 1], [-1, 0], [0, -1] ]
    DIRECTIONS_LENGTH = DIRECTIONS.length
    OKAY_DIMENSION = 0..4
  end
end

#--------------

module ToyRobot
  class Run
    COMMANDS = 'Place, Left, Right, Move & Report'

    def initialize() @robot = SafeRobot.new end

    def feed(input='') input.split("\n").each{|e| feed_line e} end

    def feed_line(input='')
      result = '' # Define in scope.
      s = input.chomp
#print 's='; p s
      tokens = tokenize s
#print 'tokens='; p tokens
      return '' if tokens.empty?
      keyword = tokens.first
#puts keyword
      result = case keyword
      when 'left'
        @robot.turn_left
      when 'move'
        @robot.move
      when 'place'
        @robot.place
      when 'report'
        @robot.report
      when 'right'
        @robot.turn_right
      else
        'Invalid keyword'
      end
      result
    end

    def startup_message
      ["Welcome to the toy robot." ,
       "Commands are #{COMMANDS}." ].join ' '
    end

    def tokenize(line)
      line.split(/[, ]/).map(&:strip).map &:downcase
    end
  end

  class Loop
    def initialize
      @robot = ToyRobot::Run.new
      puts @robot.startup_message
    end

    def run
      loop do
        s = @robot.feed_line gets
        puts s unless s.empty?
      end
    end
  end
end

# To run the automated tests, comment the Loop line below.
# To run the simulator instead, uncomment it:

# ToyRobot::Loop.new.run