# Kalkulu: processor design

## Registers

- Register 0 is the flag register, `FLAG`, which is used for storing information of the last-ran operation.
- Register 1 is the interrupt number register, `INTN`, which stores the interrupt number (if it's 0, there is no interrupt).
- Register 2 is the interrupt handler register, `INTH`, which stores the location of the interrupt handler in memory (if it's 0, there is no handler, so the handler must have at least one bit from the start of memory).
- Register 3 is the instruction pointer, `INST`, which stores the location of the current instruction in memory
- All other registers are free for use.

All instructions are given two inputs - `IN1` and `IN2`, which are either registers or binary values depending on the instruction.
The instructions can ignore one or both of the inputs (ie, `jmp` and `jz` will only use one input).

For each instruction it does the following:

1. Read the next byte from memory into `CMD`
2. Read the next byte from memory into `IN1`
3. Read the next byte from memory into `IN2`
4. Raise the `SEND` lead, which tells the system to send the values from `CMD`, `IN1`, `IN2` to the corresponding multiplexers.

The `FLAG` register stores information from the output of the last instruction:
    | bit # | name   | value                                       |
    ================================================================
    |   0   | status | 1 if instruction is successful, 0 otherwise |
    |   1   | carry  | 1 if carry required                         |
    |   2   | zero   | 1 if last instruction equated to zero       |

## Opcodes/operands and what they do

    | Opcode     | Operand            | Expression                               |
    ==============================================================================
    | 00000000   | loadr  REG1, REG2  | load location referenced by REG2 to REG1 |
    | 00000001   | loadv  REG1, VAL   | load location referenced by VAL to REG1  |
    | 00000010   | storer REG1, REG2  | save val REG2 to location REG1           |
    | 00000011   | storev REG1, VAL   | save VAL to location REG1                |
    | 00000100   | inr    REG1, REG2  | REG1 = read port number in REG2          |
    | 00000101   | inv    REG1, VAL   | REG1 = read port number VAL              |
    | 00000110   | outr   PORT, REG1  | write value in REG1 to port PORT         |
    | 00000111   | outv   PORT, VAL   | write VAL to port PORT                   |
    | 00001000   | movr   REG1, REG2  | REG1 = REG2                              |
    | 00001001   | movv   REG1, VAL   | REG1 = VAL                               |
    | 00001010   | addr   REG1, REG2  | REG1 = REG1 + REG2                       |
    | 00001011   | addv   REG1, VAL   | REG1 = REG1 + VAL                        |
    | 00001100   | subr   REG1, REG2  | REG1 = REG1 - REG2                       |
    | 00001101   | subv   REG1, VAL   | REG1 = REG1 - VAL                        |
    | 00001110   | andr   REG1, REG2  | REG1 = REG1 & REG2                       |
    | 00001111   | andv   REG1, VAL   | REG1 = REG1 & VAL                        |
    | 00010000   | orr    REG1, REG2  | REG1 = REG1 | REG2                       |
    | 00010001   | orv    REG1, VAL   | REG1 = REG1 | VAL                        |
    | 00010010   | xorr   REG1, REG2  | REG1 = REG1 xor REG2                     |
    | 00010011   | xorv   REG1, VAL   | REG1 = REG1 xor VAL                      |
    | 00010100   | shlr   REG1, REG2  | REG1 = REG1 << REG2                      |
    | 00010101   | shlv   REG1, VAL   | REG1 = REG1 << VAL                       |
    | 00010110   | shrr   REG1, REG2  | REG1 = REG1 >> REG2                      |
    | 00010111   | shrv   REG1, VAL   | REG1 = REG1 >> VAL                       |
    | 00011000   | jmpr   REG1        | jump to value in REG1                    |
    | 00011001   | jmpv   VAL         | jump to VAL                              |
    | 00011010   | jzr    REG1        | jmpr if zero flag == 0                   |
    | 00011011   | jzv    VAL         | jmpv if zero flag == 0                   |
    | 00011100   | ltr    REG1, REG2  | REG1 = REG1 < REG2                       |
    | 00011101   | ltv    REG1, VAL   | REG1 = REG1 < VAL                        |
    | 00011110   | gtr    REG1, REG2  | REG1 = REG1 > REG2                       |
    | 00011111   | gtv    REG1, VAL   | REG1 = REG1 > VAL                        |
    | 00100000   | eqr    REG1, REG2  | status flag = REG1 == REG2               |
    | 00100001   | eqv    REG1, VAL   | status flag = REG1 == VAL                |
    | 11111111   | iret               | return from interrupt                    |

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
