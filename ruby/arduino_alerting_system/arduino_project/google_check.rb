require 'io/console'
require 'rubygems'
require_relative 'alerting'


puts "Please enter your Gmail Username:\n"

username = gets.chomp

puts  "\nPlease enter your Gmail Password:\n"

password = STDIN.noecho(&:gets).chomp

puts "\nEnter the label you want to alert on:\n"

label = gets.chomp

url = "https://mail.google.com/mail/feed/atom/#{label}"

Process.daemon
alerting = false
sleep_timer = 15

alert_system = Alerting.new
loop do
  response = `curl -s --user "#{username}@/REDACTED/.com:#{password}" #{url}`

  unread_count = response[/<fullcount>(.*?)<\/fullcount>/,1].to_i
  
  if unread_count > 0 && alerting == false
    alert_system.turn_on_light
    sleep_timer = 15
    alerting = true
  elsif unread_count == 0 && alerting == true
    # call alerting.rb off
    sleep_timer = 15
    alerting = false
    alert_system.turn_off_light
  end

  # puts "You have #{unread_count} unread email(s) with the #{label} label"
  
  sleep sleep_timer
end 




