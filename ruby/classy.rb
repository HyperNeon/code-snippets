module Classy
  def class_attr_accessor *vars
    vars.each do |var|
      define_singleton_method(var) do
        class_variable_get("@@#{var}")
      end
      define_singleton_method("#{var}=") do |arg|
        class_variable_set("@@#{var}", arg)
      end
    end
  end
end
