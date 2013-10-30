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
    assert 4 == ToyRobotTable::DIRECTIONS.length
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
    bad_coordinates.zip(bad_coordinates).each do |x, y|
      @robot.reposition  [x, y]
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
end


class ToyRobotTable
  DIRECTIONS = %w[ EAST NORTH WEST SOUTH ]
  OKAY_DIMENSION = 0..4
  EDGES = [ OKAY_DIMENSION.end, OKAY_DIMENSION.end, OKAY_DIMENSION.begin, OKAY_DIMENSION.begin ]
end

class ToyRobot
  attr_reader :position
  attr_reader :direction

  def initialize
    outside_example = ToyRobotTable::OKAY_DIMENSION.begin - 1
    @position = [outside_example, outside_example]
    @direction = 'bad'
  end

  def valid?
    both_within = @position.all?{|e| ToyRobotTable::OKAY_DIMENSION.include? e}
    direction_good = ToyRobotTable::DIRECTIONS.include? @direction
    @valid = both_within && direction_good
  end

  def make_valid
    @position = [0,0]
    @direction = 'EAST'
  end

  def place(*args)
    make_valid
  end

  def orient(direction)
    @direction = direction
  end

  def reposition(point)
    @position = point
  end
end
