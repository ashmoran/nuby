module Nuby
  module VM
    module Fixcode
      module INSTR
        ADD   = 1;   # int add
        SUB   = 2;
        MUL   = 3;
        LT    = 4;   # int less than
        EQ    = 5;   # int equal
        # CALL   = 12;
        # RET    = 13;  # return with/without value
        BR    = 14;  # branch
        # BRT    = 15;  # branch if true
        # BRF    = 16;  # branch if true
        # CCONST = 17;  # push constant char
        CONST = 18;  # push constant integer
        # FCONST = 19;  # push constant float
        # SCONST = 20;  # push constant string
        # LOAD   = 21;  # load from local context
        # GLOAD  = 22;  # load from global memory
        # FLOAD  = 23;  # field load
        # STORE  = 24;  # storein local context
        # GSTORE = 25;  # store in global memory
        # FSTORE = 26;  # field store
        PRINT  = 27;  # print stack top
        # STRUCT = 28;  # push new struct on stack
        # NULL   = 29;  # push null onto stack
        # POP    = 30;  # throw away top of stack
        # HALT   = 31;
      end
    end

    class Interpreter
      include Fixcode

      def initialize(options)
        @code       = options[:fixcode]
        @output_io  = options[:output_io]

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
          when INSTR::ADD
            left, right = @operands.pop(2)
            @operands.push(left + right)
          when INSTR::SUB
            left, right = @operands.pop(2)
            @operands.push(left - right)
          when INSTR::MUL
            left, right = @operands.pop(2)
            @operands.push(left * right)
          when INSTR::LT
            left, right = @operands.pop(2)
            @operands.push(left < right)
          when INSTR::EQ
            left, right = @operands.pop(2)
            @operands.push(left == right)
          when INSTR::CONST
            @operands.push(@code[ip])
            ip += 1
          when INSTR::BR
            ip = @operands.pop
          when INSTR::PRINT
            @output_io.puts(@operands.pop)
            ip += 1
          else
            raise "Unknown instruction code: #{instruction}"
          end

          instruction = @code[ip]
        end
      end
    end
  end
end