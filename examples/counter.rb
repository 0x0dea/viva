require 'viva'

c = -1
Viva(:COUNTER).--> { c += 1 } { |v| c = v }

p Array.new(3) { $COUNTER } # => [0, 1, 2]
$COUNTER = 10
p Array.new(3) { $COUNTER } # => [11, 12, 13]
