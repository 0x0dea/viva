require 'viva'

Viva(:MoL).--> v { v * 2 } { |v| v * 7 }

$MoL = 3
p $MoL # => 42
