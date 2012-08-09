#Copyright 2012 Joseph Bergin
#License: Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License

require 'ur_robot'
require 'sensor_pack'

# A class of robots that has sensing capabilities as well as actions. 
class Robot < UrRobot
  
  include SensorPack
  
end