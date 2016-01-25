require 'viva'

Viva.define_setter('$') do |pid|
  p "Someone wanted our PID to be #{pid}."
end

%w[$ PID PROCESS_ID].each do |name|
  Viva.define_getter(name) { 1337 }
end

$$ = 42 # => "Someone wanted our PID to be 42."
p $$    # => 1337
