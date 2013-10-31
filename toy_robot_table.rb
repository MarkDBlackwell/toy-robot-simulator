=begin
=end
=begin
Author: Mark D. Blackwell
Dates:
October 31, 2013 - create

Based on:
A Test Ruby Program
From Locomote (http://www.locomote.com), an Australian based development company.

Ref:
http://rubylearning.com/blog/2011/07/28/how-do-i-test-my-code-with-minitest/

=end

require 'minitest/autorun'

class TestToyRobotTable < MiniTest::Unit::TestCase
  def setup() @table = ToyRobotTable.new end

  def test_compass_directions_must_be_in_the_correct_order
    correct_order = %w[ EAST NORTH WEST SOUTH ]
    assert_equal correct_order, ToyRobotTable::DIRECTIONS
  end

  def test_must_have_compass_directions() assert ToyRobotTable::DIRECTIONS end

  def test_must_have_four_compass_directions() assert_equal 4, ToyRobotTable::DIRECTIONS_LENGTH end
end

class TestToyRobot < MiniTest::Unit::TestCase
  def setup() @robot = ToyRobot.new end

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

  def test_can_revert
    @robot.make_valid
    direction, point = 'NORTH', [1, 1]
    @robot.orient direction
    @robot.reposition point
    assert_equal direction, @robot.direction
    assert_equal point,     @robot.position
# Revert the robot (and verify):
    @robot.revert
    assert_equal 'EAST', @robot.direction
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
    ToyRobotTable::DIRECTIONS.each do |e|
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

class TestSafeToyRobot < MiniTest::Unit::TestCase
  def setup() @robot = SafeToyRobot.new end

  def test_after_valid_place_can_move
    @robot.place
    s = @robot.move
    puts s
    assert_equal '', s
    assert_equal 'EAST', @robot.direction
    assert_equal [1, 0], @robot.position
  end

  def test_after_valid_place_can_turn_left
    @robot.place
    s = @robot.turn_left
    puts s
    assert_equal '', s
    assert_equal 'NORTH', @robot.direction
    assert_equal [0, 0], @robot.position
  end

  def test_after_valid_place_can_turn_right
    @robot.place
    s = @robot.turn_right
    puts s
    assert_equal '', s
    assert_equal 'SOUTH', @robot.direction
    assert_equal [0, 0], @robot.position
  end

  def test_before_valid_place_discards_move
    s = @robot.move
    puts s
    assert_equal 'Must start with a valid Place command', s
    assert_equal 'bad',    @robot.direction
    assert_equal [-1, -1], @robot.position
  end

  def test_before_valid_place_discards_turn_left
    s = @robot.turn_left
    puts s
    assert_equal 'Must start with a valid Place command', s
    assert_equal 'bad',    @robot.direction
    assert_equal [-1, -1], @robot.position
  end

  def test_before_valid_place_discards_turn_right
    s = @robot.turn_right
    puts s
    assert_equal 'Must start with a valid Place command', s
    assert_equal 'bad',    @robot.direction
    assert_equal [-1, -1], @robot.position
  end

  def test_report_from_custom_position
    @robot.place [2, 3], 'WEST'
    s = @robot.report
    puts s
    assert_equal 'At [2, 3], facing WEST', s
  end

  def test_report_from_default_position
    @robot.place
    s = @robot.report
    puts s
    assert_equal 'At [0, 0], facing EAST', s
  end
end

#--------------

class ToyRobot; end

class SafeToyRobot < ToyRobot

  def check_after
    valid? ? '' : (revert; 'Invalid')
  end

  def guard
    valid? ? '' : 'Must start with a valid Place command'
  end

  def move
    s = guard
    (super; s = check_after) if s.empty?
    s
  end

  def place(location=[0, 0], direction='EAST')
    super
    check_after
  end

  def report
    "At #{position}, facing #{direction}"
  end

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

class ToyRobot
  attr_reader :direction
  attr_reader :position

  def initialize
    bad_dimension_example = ToyRobotTable::OKAY_DIMENSION.begin - 1
    @position = Array.new(2){bad_dimension_example}
    @direction = 'bad'
  end

  def make_valid() reposition [0, 0]; orient 'EAST' end

  def move
    raise unless ToyRobotTable::DIRECTIONS.include? @direction
    which     =  ToyRobotTable::DIRECTIONS.index    @direction
    increment =  ToyRobotTable::DIRECTIONS_INCREMENT.at which
    new_position = @position.each_index.map{|i| (@position.at i) + (increment.at i)}
    reposition new_position
  end

  def orient(direction) @save_direction, @direction = @direction, direction end

  def place(location=[0, 0], direction='EAST')
    orient direction
    reposition location
  end

  def reposition(point) @save_position, @position = @position, point end

  def revert() @direction, @position = @save_direction, @save_position end

  def turn(increment)
    raise unless [-1, 1].include? increment
    which = ToyRobotTable::DIRECTIONS.index @direction
    sum   = ToyRobotTable::DIRECTIONS_LENGTH + which + increment
    orient  ToyRobotTable::DIRECTIONS.at sum %
            ToyRobotTable::DIRECTIONS_LENGTH
  end

  def turn_left () turn  1 end
  def turn_right() turn -1 end

  def valid?
    both_within = @position.all?{|e| ToyRobotTable::OKAY_DIMENSION.include? e}
    direction_good = ToyRobotTable::DIRECTIONS.include? @direction
    both_within && direction_good
  end
end

class ToyRobotTable
  DIRECTIONS =         %w[  EAST   NORTH     WEST    SOUTH  ]
  DIRECTIONS_INCREMENT = [ [1, 0], [0, 1], [-1, 0], [0, -1] ]
  DIRECTIONS_LENGTH = DIRECTIONS.length
  OKAY_DIMENSION = 0..4
end
