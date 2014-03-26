## Copy paste your User Token into the quotes here:
@user_token = ""

require 'dino'
require 'json'

load 'light_show.rb'

## Begin Setup
board = Dino::Board.new(Dino::TxRx::Serial.new)

@led_1 = Dino::Components::Led.new(:pin => 8,  :board => board)
@led_2 = Dino::Components::Led.new(:pin => 9,  :board => board)
@led_3 = Dino::Components::Led.new(:pin => 10, :board => board)
@led_4 = Dino::Components::Led.new(:pin => 11, :board => board)
@led_5 = Dino::Components::Led.new(:pin => 12, :board => board)
@led_6 = Dino::Components::Led.new(:pin => 13, :board => board)

@button_1 = Dino::Components::Button.new(:pin => 2, :board => board)
@button_2 = Dino::Components::Button.new(:pin => 3, :board => board)
@button_3 = Dino::Components::Button.new(:pin => 4, :board => board)
@button_4 = Dino::Components::Button.new(:pin => 5, :board => board)
@button_5 = Dino::Components::Button.new(:pin => 6, :board => board)
@button_6 = Dino::Components::Button.new(:pin => 7, :board => board)

def turn_all_off
  (1..6).each{|n| turn_off(n)}
end

def turn_all_on
  (1..6).each{|n| turn_on(n)}
end

def turn_on(number)
  @on_timer = number

  turn_all_off
  led(number).send(:on)
end

def turn_off(number)
  led(number).send(:off)
end

def led(number)
  instance_variable_get("@led_#{number}")
end

def show_error
  turn_all_on
  sleep(0.1)
  turn_all_off
  sleep(0.1)
  turn_all_on
  sleep(0.1)
  turn_all_off

  return false
end

def running_timer
  begin
    timer_status = JSON.parse(`curl 'http://tracktor.herokuapp.com/running_timer?token=#{@user_token}'`)
    if timer_status["running"] == true
      timer_status["button"]
    end
  rescue
    show_error
  end
end

## Set button reactions
@button_1.up do
  react_with_number(1)
end

@button_2.up do
  react_with_number(2)
end

@button_3.up do
  react_with_number(3)
end

@button_4.up do
  react_with_number(4)
end

@button_5.up do
  react_with_number(5)
end

@button_6.up do
  react_with_number(6)
end

def react_with_number(number)
  begin
    response = JSON.parse(`curl 'http://tracktor.herokuapp.com/toggle?button=#{number}&token=#{@user_token}'`)
    puts response

    if response["success"]
      if response["on"] == true
        turn_on(number)
      else
        turn_all_off
      end
    end
  rescue
    show_error
  end
end

## End of Setup

on_timer = running_timer

LightShow.new(@led_1, @led_2, @led_3, @led_4, @led_5, @led_6).kick_it
turn_on(on_timer) if on_timer

puts "Ready to get to work!"

# hang the code so it will listen to button clicks forever
while(true) do
  sleep(5)
  if on_timer = running_timer
    turn_on(on_timer) unless @on_timer == on_timer
  else
    turn_all_off
    @on_timer = nil
  end
end

