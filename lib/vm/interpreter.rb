module Nuby
  module VM
    module FixcodeDefinition
      INSTR_IADD   = 1;   # int add
      INSTR_ISUB   = 2;
      INSTR_IMUL   = 3;
      INSTR_ILT    = 4;   # int less than
      INSTR_IEQ    = 5;   # int equal
      # INSTR_FADD   = 6;   # float add
      # INSTR_FSUB   = 7;
      # INSTR_FMUL   = 8;
      # INSTR_FLT    = 9;   # float less than
      # INSTR_FEQ    = 10;
      # INSTR_ITOF   = 11;  # int to float
      # INSTR_CALL   = 12;
      # INSTR_RET    = 13;  # return with/without value
      # INSTR_BR     = 14;  # branch
      # INSTR_BRT    = 15;  # branch if true
      # INSTR_BRF    = 16;  # branch if true
      # INSTR_CCONST = 17;  # push constant char
      INSTR_ICONST = 18;  # push constant integer
      # INSTR_FCONST = 19;  # push constant float
      # INSTR_SCONST = 20;  # push constant string
      # INSTR_LOAD   = 21;  # load from local context
      # INSTR_GLOAD  = 22;  # load from global memory
      # INSTR_FLOAD  = 23;  # field load
      # INSTR_STORE  = 24;  # storein local context
      # INSTR_GSTORE = 25;  # store in global memory
      # INSTR_FSTORE = 26;  # field store
      INSTR_PRINT  = 27;  # print stack top
      # INSTR_STRUCT = 28;  # push new struct on stack
      # INSTR_NULL   = 29;  # push null onto stack
      # INSTR_POP    = 30;  # throw away top of stack
      # INSTR_HALT   = 31;
    end

    class Interpreter
      include FixcodeDefinition

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
          when INSTR_IADD
            left, right = @operands.pop(2)
            @operands.push(left + right)
          when INSTR_ISUB
            left, right = @operands.pop(2)
            @operands.push(left - right)
          when INSTR_IMUL
            left, right = @operands.pop(2)
            @operands.push(left * right)
          when INSTR_ILT
            left, right = @operands.pop(2)
            @operands.push(left < right)
          when INSTR_IEQ
            left, right = @operands.pop(2)
            @operands.push(left == right)
          when INSTR_ICONST
            @operands.push(@code[ip])
            ip += 1
          when INSTR_PRINT
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