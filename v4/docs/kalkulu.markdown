# Kalkulu

## Registers

Each 8-byte (64-bit) chunk of RAM is treated as a register.

`0x00`-`0x08` (first 8 bytes) is reserved as the `OUT` register, which contains the results for any non-destructive operations (undefined otherwise).
`0x08`-`0x10` (second 8 bytes) is reserved as the `FLAGS` register, which stores information about the last operation.

The first 512 bytes (`0x00`-`0x200`, or the first 64 8-byte registers) of RAM is guaranteed to be cached, if there is a cache in place.


The `FLAGS` register stores information from the output of the last instruction:

    | bit # | name   | value                                       |
    ================================================================
    | X---  | status | 1 if instruction is successful, 0 otherwise |
    | -X--  | carry  | 1 if carry required                         |
    | --X-  | zero   | 1 if last instruction equated to zero       |
    | rest  |        | reserved                                    |


All commands are formatted like the following, with unused operands set to zero:

    [4-bit opcode][64-bit operand][64-bit operand]

## Opcodes/operands and what they do

    | Opcode | Operand              | Expression                                      |
    ===================================================================================
    | 0000   | load   ADDR1, ADDR2  | ADDR1 = ADDR2                                   |
    | 0001   | loadp  ADDR1, ADDR2  | ADDR1 = value of address stored in ADDR2        |
    | 0010   | store  ADDR1, val    | ADDR1 = VAL                                     |
    | 0011   | add    ADDR1, ADDR2  | OUT = ADDR1 + ADDR2                             |
    | 0100   | and    ADDR1, ADDR2  | OUT = ADDR1 & ADDR2                             |
    | 0101   | or     ADDR1, ADDR2  | OUT = ADDR1 | ADDR2                             |
    | 0110   | xor    ADDR1, ADDR2  | OUT = ADDR1 xor ADDR2                           |
    | 0111   | shl    ADDR1, ADDR2  | OUT = ADDR1 << ADDR2                            |
    | 1000   | shr    ADDR1, ADDR2  | OUT = ADDR1 >> ADDR2                            |
    | 1001   | jz     ADDR1         | jump to ADDR1 if zero flag is set               |
    | 1010   | lt     ADDR1, ADDR2  | status flag = ADDR1 < ADDR2                     |
    | 1011   | gt     ADDR1, ADDR2  | status flag = ADDR1 > ADDR2                     |
    | 1100   |
    | 1101   | iret                 | return from interrupt                           |
    | 1110   | in     ADDR1         | OUT = read port number specified in ADDR1       |
    | 1111   | out    ADDR1, ADDR2  | write value in ADDR2 to port specified in ADDR2 |

### "Missing" opcodes

    jmp ADDR1
        or FLAGS, 0b0100
        jz ADDR1
    
    eq ADDR1, ADDR2
        xor ADDR1, ADDR2
    
    sub ADDR1, ADDR2
        TODO

