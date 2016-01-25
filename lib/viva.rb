require 'viva/core'

module Viva
  module_function

  def define_getter var
    define var, proc, Setters["$#{var}"]
  end

  def define_setter var
    define var, Getters["$#{var}"], proc
  end

  def undef_getter var
    Getters.delete "$#{var}"
  end

  def undef_setter var
    Setters.delete "$#{var}"
  end

  def - getter, &setter
    define @var, getter, setter
  end
end

module Kernel
  module_function def Viva var
    Viva.tap { |v| v.instance_variable_set :@var, var }
  end
end
