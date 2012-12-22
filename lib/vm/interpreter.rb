module Nuby
  module VM
    class FunctionSymbol
      attr_reader :address, :num_args

      def initialize(attributes)
        @name     = attributes.fetch(:name)
        @address  = attributes.fetch(:address)
        @num_args = attributes.fetch(:num_args, 0)
      end

      def to_s
        "<FunctionSymbol: name=#{@name} address=#{@address}> num_args=#{@num_args}"
      end
    end

    # A simple stack-based "bytecode" interpereter. The machine code it
    # processes is called "fixcode" because it's not really bytecode, it's
    # an array of Fixnums (and Nils and ...). I decided to break away from
    # the strict bytecode in the book example because of the extra overhead
    # of doing low-level byte manipulation in Ruby. This VM is definitely
    # aimed at a more Ruby-like language.
    class Interpreter
      def initialize(options)
        @code       = options.fetch(:fixcode)
        @constants  = options.fetch(:constants, [ ])
        @output_io  = options.fetch(:output_io)

        @globals    = [ ]
        @call_stack = [ ]
        @locals     = [ ] # Will be extracted into a stack frame
        @operands   = [ ]
      end

      def exec
        run_cpu
      end

      def run_cpu
        ip = 0
        instruction = @code[ip]

        while ip < @code.length
          ip += 1

          case instruction
          when :add
            left, right = @operands.pop(2)
            @operands.push(left + right)
          when :sub
            left, right = @operands.pop(2)
            @operands.push(left - right)
          when :mul
            left, right = @operands.pop(2)
            @operands.push(left * right)
          when :lt
            left, right = @operands.pop(2)
            @operands.push(left < right)
          when :eq
            left, right = @operands.pop(2)
            @operands.push(left == right)
          when :call
            function = @constants[@code[ip]]
            @locals = @operands.pop(function.num_args)
            @call_stack.push(ip + 1)
            ip = function.address
          when :ret
            # Naively just storing the address for now
            ip = @call_stack.pop
          when :br
            ip = @operands.pop
          when :brt
            condition, address = @operands.pop(2)
            ip = address if condition
          when :brf
            condition, address = @operands.pop(2)
            ip = address unless condition
          when :const
            @operands.push(@code[ip])
            ip += 1
          when :load
            @operands.push(@locals[@code[ip]])
            ip += 1
          when :gload
            @operands.push(@globals[@code[ip]])
            ip += 1
          when :store
            @locals[@code[ip]] = @operands.pop
            ip += 1
          when :gstore
            @globals[@code[ip]] = @operands.pop
            ip += 1
          when :print
            @output_io.puts(@operands.pop)
          when :nil
            @operands.push(nil)
          when :pop
            @operands.pop
          when :halt
            break
          else
            raise "Unknown instruction code: #{instruction.inspect}"
          end

          instruction = @code[ip]
        end
      end
    end
  end
end