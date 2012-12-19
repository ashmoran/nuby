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

[lipbook]: http://pragprog.com/book/tpdsl/language-implementation-patterns
[parrt]: http://www.cs.usfca.edu/~parrt/
[liprepo]: https://github.com/ashmoran/language_implementation_patterns