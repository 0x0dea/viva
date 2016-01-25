require 'minitest/autorun'
require 'minitest/pride'
require 'viva'

describe Viva do
  describe '.define' do
    describe 'when given a valid virtual variable name' do
      it 'should return its name as a globalized Symbol' do
        [0, -4, '$', '-_', Viva, :*].each do |name|
          expected = :"$#{name}"
          Viva.define(name, nil, nil).must_equal expected
        end
      end
    end

    describe 'when given an invalid virtual variable name' do
      it 'should complain and refrain (inaccessible < useless)' do
        [1, -10, ' ', '_-', nil, :^,].each do |name|
          -> { Viva.define name, nil, nil }.must_raise NameError
        end
      end
    end

    # NOTE: These next two specs are essentially identical.
    # How does one verify that nonexistent code didn't run?

    it 'should be able to create a getter with no setter' do
      Viva.define :a, -> actual { actual * 2 }, nil
      $a = 21
      $a.must_equal 42
    end

    it 'should be able to create a setter with no getter' do
      Viva.define :b, nil, -> actual { actual * 2 }
      $b = 21
      $b.must_equal 42
    end
  end

  # This more or less runs the thing through its paces, so let's stop here.

  it "should be able to emulate GCC's __COUNTER__ (with bonus reset)" do
    c = -1
    Viva(:COUNTER).--> { c += 1 } { |v| c = v }

    Array.new(3) { $COUNTER }.must_equal [0, 1, 2]
    $COUNTER = 10
    Array.new(3) { $COUNTER }.must_equal [11, 12, 13]
  end
end
