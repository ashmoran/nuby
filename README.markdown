# Nuby

A simple Ruby-like language, compiler, and virtual machine, written in Ruby

## What?

This is a small educational project to make:

* A simple stack-based bytecode virtual machine
* An assembler to compile assembly language to bytecode for the VM
* A compiler to compile a simple Ruby-like language (Nuby) to VM assembly
* A spec for the source language Nuby

## Why?

I've been working through the book [Language Implementation Patterns][lipbook] by [Terrence Parr][parrt], implementing some of the patterns (to some level of thoroughness) in Ruby. My efforts are in my [language\_implementation\_patterns][liprepo] repository.

I got as far as the virtual machine implementation patterns before deciding I'd like to try making a full compiler pipeline.

## Notes

Run `rake guard` and `rake bundle` to use 1.9.3 where necessary. It doesn't look like _rb-fsevent_ works in Rubinius right now:

    ➜  nuby  irb
    require 'rubinius-2.0.0rc1 :001 > require 'rb-fsevent'
     => true
    rubinius-2.0.0rc1 :002 > require 'listen'
     => true
    rubinius-2.0.0rc1 :003 > Listen.to(".", filter: /\.rb$/) { |m, a, r| puts "Listen:"; p m; p a; p r }
    Errno::EBADF: Bad file descriptor - select(2) failed
        from kernel/common/io.rb:358:in `select'
        from /Users/ashmoran/.rvm/gems/rbx-head/gems/rb-fsevent-0.9.2/lib/rb-fsevent/fsevent.rb:40:in `run'
        from /Users/ashmoran/.rvm/gems/rbx-head/gems/listen-0.6.0/lib/listen/adapters/darwin.rb:31:in `start'
        from kernel/bootstrap/thread19.rb:41:in `__run__'

[lipbook]: http://pragprog.com/book/tpdsl/language-implementation-patterns
[parrt]: http://www.cs.usfca.edu/~parrt/
[liprepo]: https://github.com/ashmoran/language_implementation_patterns