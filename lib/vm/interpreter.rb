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

    class StackFrame
      attr_reader :locals, :return_address

      def initialize(attributes)
        @locals = attributes.fetch(:locals, [ ])
        @return_address = attributes.fetch(:return_address)
      end

      def to_s
        "<StackFrame: locals=#{@locals.inspect} return_address=#{@return_address}>"
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
        @main      = options.fetch(:main, FunctionSymbol.new(name: "main", address: 0))
        @code      = options.fetch(:fixcode)
        @constants = options.fetch(:constants, [ ])
        @output_io = options.fetch(:output_io)

        @globals    = [ ]
        @call_stack = [ ]
        @operands   = [ ]
      end

      def exec
        @call_stack.push(StackFrame.new(return_address: -1))
        @ip = @main.address
        run_cpu
      end

      def run_cpu
        catch(:halt) do
          while @ip < @code.length
            instruction = @code[@ip]
            @ip += 1

            exec_instruction(instruction)
          end
        end
      end

      private

      def exec_instruction(instruction)
        instruction_method = :"instr_#{instruction}"
        if respond_to?(instruction_method)
          send(instruction_method)
        else
          raise "Unknown instruction: #{instruction.inspect}"
        end
      end

      def self.instruction(instruction_name, &block)
        define_method(:"instr_#{instruction_name}", &block)
      end

      instruction :add do
        left, right = @operands.pop(2)
        @operands.push(left + right)
      end

      instruction :sub do
        left, right = @operands.pop(2)
        @operands.push(left - right)
      end

      instruction :mul do
        left, right = @operands.pop(2)
        @operands.push(left * right)
      end

      instruction :div do
        left, right = @operands.pop(2)
        @operands.push(left / right)
      end

      instruction :lt do
        left, right = @operands.pop(2)
        @operands.push(left < right)
      end

      instruction :eq do
        left, right = @operands.pop(2)
        @operands.push(left == right)
      end

      instruction :call do
        function = @constants[@code[@ip]]
        @call_stack.push(
          StackFrame.new(
            locals:         @operands.pop(function.num_args),
            return_address: @ip + 1
          )
        )
        @ip = function.address
      end

      instruction :ret do
        @ip = @call_stack.pop.return_address
      end

      instruction :br do
        @ip = @operands.pop
      end

      instruction :brt do
        condition, address = @operands.pop(2)
        @ip = address if condition
      end

      instruction :brf do
        condition, address = @operands.pop(2)
        @ip = address unless condition
      end

      instruction :gload do
        @operands.push(@globals[@code[@ip]])
        @ip += 1
      end

      instruction :gstore do
        @globals[@code[@ip]] = @operands.pop
        @ip += 1
      end

      instruction :load do
        stack_frame = @call_stack.last
        @operands.push(stack_frame.locals[@code[@ip]])
        @ip += 1
      end

      instruction :store do
        stack_frame = @call_stack.last
        stack_frame.locals[@code[@ip]] = @operands.pop
        @ip += 1
      end

      instruction :const do
        @operands.push(@code[@ip])
        @ip += 1
      end

      instruction :nil do
        @operands.push(nil)
      end

      instruction :print do
        @output_io.puts(@operands.pop)
      end

      instruction :pop do
        @operands.pop
      end

      instruction :halt do
        throw :halt
      end
    end
  end
end