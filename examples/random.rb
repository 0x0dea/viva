require 'viva'

max = 32768
getter = -> { rand max }
setter = -> spec { max = spec }

Viva.define :RANDOM, getter, setter

p Array.new(4) { $RANDOM }
$RANDOM = 1..6
p Array.new(4) { $RANDOM }
