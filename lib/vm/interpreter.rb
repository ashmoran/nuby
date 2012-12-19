module Nuby
  module VM
    module Fixcode
      module INSTR
        IADD   = 1;   # int add
        ISUB   = 2;
        IMUL   = 3;
        ILT    = 4;   # int less than
        IEQ    = 5;   # int equal
        # FADD   = 6;   # float add
        # FSUB   = 7;
        # FMUL   = 8;
        # FLT    = 9;   # float less than
        # FEQ    = 10;
        # ITOF   = 11;  # int to float
        # CALL   = 12;
        # RET    = 13;  # return with/without value
        # BR     = 14;  # branch
        # BRT    = 15;  # branch if true
        # BRF    = 16;  # branch if true
        # CCONST = 17;  # push constant char
        ICONST = 18;  # push constant integer
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
          when INSTR::IADD
            left, right = @operands.pop(2)
            @operands.push(left + right)
          when INSTR::ISUB
            left, right = @operands.pop(2)
            @operands.push(left - right)
          when INSTR::IMUL
            left, right = @operands.pop(2)
            @operands.push(left * right)
          when INSTR::ILT
            left, right = @operands.pop(2)
            @operands.push(left < right)
          when INSTR::IEQ
            left, right = @operands.pop(2)
            @operands.push(left == right)
          when INSTR::ICONST
            @operands.push(@code[ip])
            ip += 1
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