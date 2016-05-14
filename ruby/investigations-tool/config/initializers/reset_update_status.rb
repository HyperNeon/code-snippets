# Since the update status may get stuck at true if we turn off the app while something is updating
# let's reset all the update statuses 

# Wrapping this initializer in an if statement that checks if the update_status field exists 
# since initializers are called during asset precompile for capistrano and this field won't
# exist yet

if defined?(Investigation) && Investigation.new.attributes.include?("update_status")
  Investigation.clear_all_update_status
end