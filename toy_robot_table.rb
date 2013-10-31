=begin
=end
=begin

Based on:
http://rubylearning.com/blog/2011/07/28/how-do-i-test-my-code-with-minitest/

=end

require 'minitest/autorun'

class TestToyRobotTable < MiniTest::Unit::TestCase
  def setup
    @table = ToyRobotTable.new
  end

  def test_must_have_compass_directions
    assert ToyRobotTable::DIRECTIONS
  end

  def test_must_have_four_compass_directions
    assert 4 == ToyRobotTable::DIRECTIONS_LENGTH
  end

  def test_compass_directions_must_be_in_the_correct_order
    correct_order = %w[ EAST NORTH WEST SOUTH ]
    assert correct_order == ToyRobotTable::DIRECTIONS
  end

  def test_must_have_edges
    assert ToyRobotTable::EDGES
  end

  def test_edges_must_be_in_the_correct_order
    correct_order = [ 4, 4, 0, 0 ]
    assert correct_order == ToyRobotTable::EDGES
  end
end

class TestToyRobot < MiniTest::Unit::TestCase
  def setup
    @robot = ToyRobot.new
  end

  def test_invalid_before_the_first_place_command
    assert ! @robot.valid?
  end

  def test_valid_after_the_first_place_command
    @robot.place
    assert @robot.valid?
  end

  def test_can_reposition
    sample = [-1, -1]
    @robot.reposition sample
    assert sample == @robot.position
  end

  def test_valid_after_repositioning_with_good_coordinates
    @robot.make_valid
    good_coordinates = [0, 0]
    @robot.reposition good_coordinates
    assert @robot.valid?
  end

  def test_invalid_after_repositioning_with_bad_coordinates
    @robot.make_valid
    bad_coordinates = [-1, 5]
    bad_coordinates.zip(bad_coordinates).each do |x,y|
      @robot.reposition [x, y]
      assert ! @robot.valid?, "(x,y) was (#{x},#{y})"
    end
  end

  def test_can_orient
    sample = 'any direction'
    @robot.orient(sample)
    assert sample == @robot.direction
  end

  def test_valid_after_orienting_in_good_direction
    @robot.make_valid
    ToyRobotTable::DIRECTIONS.each do |e|
      @robot.orient e
      assert @robot.valid?
    end
  end

  def test_invalid_after_orienting_in_bad_direction
    @robot.make_valid
    bad_direction = 'bad'
    @robot.orient bad_direction
    assert ! @robot.valid?
  end

  def test_can_revert
    @robot.make_valid
    direction, point = 'NORTH', [1, 1]
    @robot.orient direction
    @robot.reposition point
    assert_equal direction, @robot.direction
    assert_equal point,     @robot.position
    @robot.revert
    assert_equal 'EAST', @robot.direction
    assert_equal [0, 0], @robot.position
  end

  def test_can_move
    @robot.make_valid
    @robot.move
    assert_equal 'EAST', @robot.direction
    assert_equal [1, 0], @robot.position
    @robot.make_valid
    direction = 'NORTH'
    @robot.orient direction
    @robot.move
    assert_equal direction, @robot.direction
    assert_equal [0, 1],    @robot.position
  end

  def test_can_turn_left
    @robot.make_valid
    @robot.turn_left
    assert_equal 'NORTH', @robot.direction
    @robot.turn_left
    assert_equal 'WEST',  @robot.direction
    @robot.turn_left
    assert_equal 'SOUTH', @robot.direction
    @robot.turn_left
    assert_equal 'EAST',  @robot.direction
  end

  def test_can_turn_right
    @robot.make_valid
    @robot.turn_right
    assert_equal 'SOUTH', @robot.direction
    @robot.turn_right
    assert_equal 'WEST',  @robot.direction
    @robot.turn_right
    assert_equal 'NORTH', @robot.direction
    @robot.turn_right
    assert_equal 'EAST',  @robot.direction
  end
end

class TestSafeToyRobot < MiniTest::Unit::TestCase
  def setup
    @robot = ToyRobot.new
  end
end

class ToyRobotTable
  DIRECTIONS =         %w[  EAST   NORTH     WEST    SOUTH  ]
  DIRECTIONS_INCREMENT = [ [1, 0], [0, 1], [-1, 0], [0, -1] ]
  DIRECTIONS_LENGTH = DIRECTIONS.length
  OKAY_DIMENSION = 0..4
  EDGES = [ OKAY_DIMENSION.end,   OKAY_DIMENSION.end,
            OKAY_DIMENSION.begin, OKAY_DIMENSION.begin ]
end

class ToyRobot
  attr_reader :direction
  attr_reader :position

  def initialize
    bad_dimension_example = ToyRobotTable::OKAY_DIMENSION.begin - 1
    @position = [bad_dimension_example, bad_dimension_example]
    @direction = 'bad'
  end

  def valid?
    both_within = @position.all?{|e| ToyRobotTable::OKAY_DIMENSION.include? e}
    direction_good = ToyRobotTable::DIRECTIONS.include? @direction
    both_within && direction_good
  end

  def make_valid
    reposition [0, 0]
    orient 'EAST'
  end

  def place(*args)
    make_valid
  end

  def orient(direction) @save_direction, @direction = @direction, direction end

  def reposition(point) @save_position, @position = @position, point end

  def revert() @direction, @position = @save_direction, @save_position end

  def move
    raise unless ToyRobotTable::DIRECTIONS.include? @direction
    which     =  ToyRobotTable::DIRECTIONS.index    @direction
    increment =  ToyRobotTable::DIRECTIONS_INCREMENT.at which
    new_position = @position.each_index.map{|i| (@position.at i) + (increment.at i)}
    reposition new_position
  end

  def turn_left () turn  1 end
  def turn_right() turn -1 end

  def turn(increment)
    raise unless [-1, 1].include? increment
    which = ToyRobotTable::DIRECTIONS.index @direction
    sum   = ToyRobotTable::DIRECTIONS_LENGTH + which + increment
    orient  ToyRobotTable::DIRECTIONS.at(sum %
            ToyRobotTable::DIRECTIONS_LENGTH)
  end
end

class SafeToyRobot < ToyRobot

  def move
    super
    revert unless valid?
  end

  def turn_left
    super
    revert unless valid?
  end

  def turn_right
    super
    revert unless valid?
  end

  def place
    super
    revert unless valid?
  end
end
