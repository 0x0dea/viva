<p align="center">
  <img src="http://i.imgur.com/OzCBizi.png" />
</p>

## What's this?

**Viva** is a little C extension that exposes the **vi**rtual **va**riable API to Ruby land for science and the lulz.

### What's that?

Contrary to popular misconception, many of Ruby's global variables are in fact not. Consider the case of `$~` (known to [`English`](http://ruby-doc.org/stdlib-2.3.0/libdoc/English/rdoc/English.html) speakers as `$LAST_MATCH_INFO`):

```ruby
def foo
  'foo'.match /\w+/ and p $~
end

'bar'.match /\w+/

p $~ # "bar" from the current scope
foo  # "foo" from #foo's scope
p $~ # "bar" again
```

It's evident that something tricksy is going on here; if this allegedly "global" variable doesn't maintain its value across scopes, whence does it come? I'll spare you the gory details: it's defined in terms of [a pair of C functions](https://git.io/vzwAN). Referring to `$~` will invoke `match_getter()` to obtain a value and *assigning to `$~`* will cause the provided `MatchData` instance to be used for `$~` and all of its descendants (of which there are [potentially thousands](https://git.io/vzwxR)).

#### Cool story, bro.

That's all well and good, yeah? "vvars" are scoped and pretty much do The Right Thing™. What's more, there's nothing stopping you from digging in and defining your own. But who wants to write C? [Bestest](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=4&cad=rja&uact=8&ved=0ahUKEwjqlvHc4L_KAhVF4iYKHRAZAxMQFggzMAM&url=http%3A%2F%2Fwww.merriam-webster.com%2Fdictionary%2Fbestest&usg=AFQjCNF5NASit_I0DsFXBB2l4baH0n7nFQ&bvm=bv.112454388,d.eWE) of all would be if we could define virtual getters and setters with Ruby callables, and so I've made that a thing.

### La raison d'être

There's an old shell variable in Zsh—I know it's in Bash, it's probably in Zsh—called `RANDOM`, and the tin's not lying:

```bash
$ echo $RANDOM $RANDOM $RANDOM
8784 15644 1499
```

[How neat is that?](http://i.imgur.com/SCRFkTZ.png) Let's give Ruby a `$RANDOM` that's neater still:

```ruby
require 'viva'

max = 32768 # Be like Bash... for now.
getter = -> { rand max }
setter = -> spec { max = spec }

Viva.define :RANDOM, getter, setter

p Array.new(4) { $RANDOM }
# => [31791, 5045, 21337, 14134]

$RANDOM = 1..6

p Array.new(4) { $RANDOM }
# => [3, 5, 6, 2]
```

Bash's offering looks positively static in comparison. ¡Viva la Rubylución!

## Usage

`Viva.define` is the primary interface. It accepts exactly three arguments: a name for the virtual variable to be defined and two callables (instances of `Method` or `Proc`) to be used as the getter and setter thereof, respectively.

The name is coerced via `Kernel#String`; preceded with a `'$'`; and subjected to the rules for global identifiers, with the additional stipulation that numeric names may only be between `-9` and `0`, inclusively. This constraint is informed by the parser rather than enforced by the virtual variable API: `$-10` and below are outright syntax errors, and assignment to the positives is explicitly forbidden. We can *refer* to them just fine, but they're "super-virtual" and will, at present, simply ignore any efforts to tailor their behavior to one's wily whim. I consider the inability to use them to be a :bug: in **Viva**.

**TL;DR;SMAT**:

 valid |invalid
:-----:|:-----:
`0`    |`1`
`-4`   |`-10`
`"$"`  |`" "`
`"-_"` |`"_-"`
`Viva` |`nil`
`:*`   |`:^`

The getter can be defined to take an argument, which will be the "actual" value of the requested variable. Likewise, the setter receives the value that was assigned. The point, of course, is that you're free to do with these values what you will.

Invoking `Viva.define` with a falsy value instead of a callable will undefine it and restore that operation to its regularly scheduled programming (bog-standard retrieval and assignment); regrettably, this holds true for variables which previously had some special meaning (pretty much everything in `English`). This is another :bug:.

`define_getter` and `define_setter` are convenience methods that take blocks and leave their better halves in place:

```ruby
Viva.define_setter('$') do |pid|
  p "Someone wanted our PID to be #{pid}."
end

%w[$ PID PROCESS_ID].each do |name|
  Viva.define_getter(name) { 1337 }
end

$$ = 42 # => "Someone wanted our PID to be 42."
p $$    # => 1337
```

Just for laughs, **Viva** provides a bit of syntactic sugalt for defining both accessors simultaneously using "two blocks":

```ruby
Viva(:MoL).--> v { v * 2 } { |v| v * 7 }

$MoL = 3
p $MoL # => 42
```

That you have to put the parameter in different places makes it look pretty silly, which I argue is a feature.

Finally, there's `undef_getter` and `undef_setter` which, while perfectly self-explanatory, go a long way toward revealing what's actually going on here:

```ruby
def undef_getter var
  Getters.delete "$#{var}"
end
```

No effort has been made to conceal the internals from the user. This one's for you, [`FrozenCore`](https://youtu.be/SBdqCYKWISU?t=463).

### FQAs

* Is this real life?

Likelier than not, but perhaps one of the solipsists has the right of it.

* Why is this happening?

Some men just want to watch the world-writable variables burn with the glory of a thousand suns. <sup><sup>If only I could be so grossly incandescent...</sup></sup>

* Should I use this?

I'm inclined to think [_why would've liked it](http://favstar.fm/users/_why/status/1231698950); your team are liable to [respond less positively](https://www.youtube.com/watch?v=H07zYvkNYL8). Horses for courses and the like.

### Contributing

You are strongly but gently advised to reconsider. If you simply won't be deterred, may the fork be with you.
