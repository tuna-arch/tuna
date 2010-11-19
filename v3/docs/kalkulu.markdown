# Kalkulu: processor design

*WIDTH* is the width of the data bus: 4 bit, 16 bit, 32 bit, 64 bit, etc.

## Registers

- Register 0 is the flag register, `FLAG`, which is used for storing information of the last-ran operation.
- Register 1 is the interrupt number register, `INTN`, which stores the interrupt number (if it's 0, there is no interrupt).
- Register 2 is the interrupt handler register, `INTH`, which stores the location of the interrupt handler in memory (if it's 0, there is no handler, so the handler must have at least one bit from the start of memory).
- Register 3 is the instruction pointer, `INST`, which stores the location of the current instruction in memory
- All other registers are free for use.

All instructions are given two inputs - `IN1` and `IN2`, which are either registers or binary values depending on the instruction.
The instructions can ignore one or both of the inputs (ie, `jmp` and `jz` will only use one input).

For each instruction it does the following:

1. Read the next nibble (four bits) from memory into `CMD`
2. Read the next 32 bits from memory into `IN1`
3.   - if the command is `mov`: Read the next *WIDTH* bits from memory into `IN2`
     - otherwise: Read the next 32 bits from memory into `IN2`
4. Raise the `SEND` lead, which tells the system to send the values from `CMD`, `IN1`, `IN2` to the corresponding multiplexers.

The `FLAG` register stores information from the output of the last instruction:
    | bit # | name   | value                                       |
    ================================================================
    |   0   | status | 1 if instruction is successful, 0 otherwise |
    |   1   | carry  | 1 if carry required                         |
    |   2   | zero   | 1 if last instruction equated to zero       |

## Opcodes/operands and what they do

    | Opcode | Operand            | Expression                               |
    ==========================================================================
    | 0000   | mov    REG1, VAL   | REG1 = VAL                               |
    | 0001   | load   REG1, REG2  | load location referenced by REG2 to REG1 |
    | 0010   | store  REG1, REG2  | save val REG2 to location REG1           |
    | 0011   | in     REG1, REG2  | REG1 = read port number in REG2          |
    | 0100   | out    PORT, REG1  | write value in REG1 to port PORT         |
    | 0101   | add    REG1, REG2  | REG1 = REG1 + REG2                       |
    | 0110   | and    REG1, REG2  | REG1 = REG1 & REG2                       |
    | 0111   | or     REG1, REG2  | REG1 = REG1 | REG2                       |
    | 1000   | xor    REG1, REG2  | REG1 = REG1 xor REG2                     |
    | 1001   | shl    REG1, REG2  | REG1 = REG1 << REG2                      |
    | 1010   | shr    REG1, REG2  | REG1 = REG1 >> REG2                      |
    | 1011   | jmp    REG1        | jump to value in REG1                    |
    | 1100   | jz     REG1        | jump if zero flag == 1                   |
    | 1101   | lt     REG1, REG2  | status flag = REG1 < REG2                |
    | 1110   | gt     REG1, REG2  | status flag = REG1 > REG2                |
    | 1111   | iret               | return from interrupt                    |

## Interrupts

A device, upon establishing communication with the processor, can request a port number.
When the port number is given, it can send a interrupt request for that port number at any given time.
When it does so, the processor will set `INTN` to the port number and trigger the interrupt handler (if `INTH` is not set to 0).

You can use the `iret` instruction to leave the interrupt handler

Example interrupt handler implementation:

    int_handler:
      out 0, INTN ; print interrupt number
      iret        ; leave interrupt
    
    movv INTH, int_handler ; set interrupt handler
