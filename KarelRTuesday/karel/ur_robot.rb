#Copyright 2012 Joseph Bergin
#License: Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License

require "robota"
require "observer"
require "monitor"

# The simplest kind of instantiable robot. Has all of the capabilities defined in Robota
class UrRobot < Robota
  include Observable
  
  # attr_reader :direction
  
  # Place a robot at a given corner (street, avenue) facing a given direction, with an initial
  # number of beepers in its beeper bag
  # If color is nil its background will appear transparent, otherwise a robot will appear to carry a shield
  # of the given color, say :red or :blue. 
  def initialize(street, avenue, direction, beepers, color = nil)
    super(street, avenue, direction, beepers)
    @runstate = true
    @color = color
    add_observer(Robota::World)
    changed
    notify_observers(self, CREATE_ACTION, state)
    @pausing = false
    @userPausing = false
  end
  
  def clone()
    result = super()
    result.add_observer(Robota::World)
    result.changed
    result.notify_observers(result, CREATE_ACTION, state)
    result
  end
  
  # def color
    # return @color
  # end
#   
  
  def state
    return [@street, @avenue, @direction, @beepers, @runstate, @color]
  end
  
  def running?
    return @runstate
  end
  
  private :state
  
  def show_state(msg)
    puts msg + ' ' + state.to_s  
  end
  
  # Move one block in the current direction (provided the front is clear)
  def move
    pause("move")
    raise RobotNotRunning, " while moving" if ! @runstate
    begin
      @street = @direction.next_street(@street, @avenue)
      @avenue = @direction.next_avenue(@street, @avenue)
      #    if @street < 1 || @avenue < 1
      #      self.turn_off
      #      raise  FrontIsBlocked, "(" + @street.to_s + ", " + @avenue.to_s + ")"
      #    end
    rescue FrontIsBlocked
      self.turn_off
      raise
    end
    #    Robota::World.register_robot(self, [@street, @avenue, @direction])
    changed
    notify_observers(self, MOVE_ACTION, state)
    self
  end
  
  # Turn 90 degrees to the left from the current direction
  def turn_left
    pause("turn_left")
    raise RobotNotRunning, " while turning left" if ! @runstate
    @direction = @direction.next
    #    Robota::World.register_robot(self, [@street, @avenue, @direction])
    changed
    notify_observers(self, TURN_LEFT_ACTION, state)
    self
  end
  
  # Pick a beeper from the current corner (provided there is one to pick)
  def pick_beeper
    pause("pick_beeper")
    raise RobotNotRunning, " while picking a beeper" if ! @runstate
    if Robota::World.beepers_at?(@street, @avenue)
      if @beepers != Robota::INFINITY
        @beepers += 1      
      end
      Robota::World.remove_beeper(@street, @avenue)
    else
      self.turn_off
      raise NoBeepers,  "(#@street, #@avenue)"
    end
    changed
    notify_observers(self, PICK_BEEPER_ACTION, state)
    self
  end
  
  # Put a beeper on the current corner (provided the robot has one in the beeper bag)
  def put_beeper
    pause("put_beeper")
    raise RobotNotRunning, " while putting a beeper" if ! @runstate
    if @beepers == Robota::INFINITY
      # nothing
    elsif @beepers < 1
      self.turn_off
      raise NoBeepersInBeeperBag, "(#@street, #@avenue)"
    else
      @beepers -= 1
    end
    Robota::World.place_beepers(@street, @avenue, 1, true)
    changed
    notify_observers(self, PUT_BEEPER_ACTION, state)
    self
  end
  
  # Turn off, making further actions impossible
  def turn_off
    pause("turn_off")
    @runstate = false;
    changed
    notify_observers(self, TURN_OFF_ACTION, state)
    self
  end
  
  # Returns a collection of the other robots on the same corner as this robot
  # if a block is given, the block will be applied to each neighbor 
  def neighbors
    result = Robota::World.neighbors_of(self, @street, @avenue)
    if block_given?
      for neighbor in result
        yield neighbor
      end
    end
    result = [] if result == nil
    return result
  end
  
  
  def pause(action)
    # if not $thread_release
      # $thread_monitor.wait_until{$thread_release}
    # end
    return if ! @pausing
    puts "Robot with ID: #@ID is about to #{action}."
    STDIN.gets  
  end
  
  def set_pausing(pause = true)
    @pausing = pause
  end
  
  
end