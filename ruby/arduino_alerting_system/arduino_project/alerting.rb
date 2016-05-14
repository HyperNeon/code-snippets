class Alerting
  require "serialport"
  
  arduino_name = `ls /dev/ | grep tty.usbmodem`.chomp
  @port_str = "/dev/#{arduino_name}"
  @@sp = SerialPort.new(@port_str, 9600)

  def turn_off_light
  	# port_str = "/dev/tty.usbmodem1421"
  	# sp = SerialPort.new(port_str, 9600)  
    @@sp.write '0'
  end
  
  def turn_on_light
  	# port_str = "/dev/tty.usbmodem1421"
  	# sp = SerialPort.new(port_str, 9600)    
    @@sp.write '1'
  end

end