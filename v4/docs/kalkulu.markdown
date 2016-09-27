# Kalkulu

## Registers

Each 8-byte (64-bit) chunk of RAM is treated as a register.

`0x00`-`0x08` (first 8 bytes) is reserved as the `OUT` register, which contains the results for any non-destructive operations (undefined otherwise).
`0x08`-`0x10` (second 8 bytes) is reserved as the `FLAGS` register, which stores information about the last operation.

The registers may optionally be cached, making them quicker to access than RAM.

The `FLAGS` register stores information from the output of the last instruction:

    | bit #      | name   | value                                  |
    ================================================================
    | ---- ---x  | carry  | 1 if carry required                    |
    | ---- --x-  | zero   | 1 if last instruction equated to zero  |
    | rest       |        | reserved                               |


All commands are formatted as follows, with unused operands set to zero:

    [8-bit opcode][8-bit operand][8-bit operand]

The first four bits of the opcode are modifiers, the second four bits are the actual opcode.

Modifiers:

    | bit   | name    | purpose
    ==============================
    | x---  |         | reserved  |
    | -x--  |         | reserved  |
    | --x-  |         | reserved  |
    | ---x  | pointer | designates whether the operand is an address to retrieve the value from. 0 = value, 1 = pointer. |

## Opcodes/operands and what they do

Each opcode only requires one implementation; the Pointer modifier changes the behavior of the fetcher stage, and is completely transparent to the rest of the system.

    | Modifier | Opcode | Operand              | Expression                                       |
    ===============================================================================================
    | 0000     | 0000   | mov   ADDR1, VALUE   | ADDR1 = VALUE                                    |
    | 0001     | 0000   | movp  ADDR1, ADDR2   | ADDR1 = value of ADDR2                           |
    |                                                                                             |
    | 0000     | 0001   | add   ADDR1, VALUE   | OUT = ADDR1 + VALUE                              |
    | 0001     | 0001   | addp  ADDR1, ADDR2   | OUT = ADDR1 + value of ADDR2                     |
    |                                                                                             |
    | 0000     | 0010   | nand  ADDR1, VALUE   | OUT = ADDR1 nand VALUE                           |
    | 0001     | 0010   | nandp ADDR1, ADDR2   | OUT = ADDR1 nand (value of ADDR2)                |
    |                                                                                             |
    | 0000     | 0011   | xor   ADDR1, VALUE   | OUT = ADDR1 xor VALUE                            |
    | 0001     | 0011   | xorp  ADDR1, ADDR2   | OUT = ADDR1 xor (value of ADDR2)                 |
    |                                                                                             |
    | 0000     | 0100   | shl   ADDR1, VALUE   | OUT = ADDR1 << VALUE                             |
    | 0001     | 0100   | shlp  ADDR1, ADDR2   | OUT = ADDR1 << (value of ADDR2)                  |
    |                                                                                             |
    | 0000     | 0101   | shr   ADDR1, VALUE   | OUT = ADDR2 >> VALUE                             |
    | 0001     | 0101   | shrp  ADDR1, ADDR2   | OUT = ADDR2 >> (value of ADDR2)                  |
    |                                                                                             |
    |          | 0110   | jz    ADDR1          | jump to ADDR1 if zero flag is set                |
    |                                                                                             |
    | 0000     | 0111   | lt    ADDR1, VALUE   | status flag = ADDR1 < ADDR2                      |
    | 0001     | 0111   | lt    ADDR1, ADDR2   | status flag = ADDR1 < (value of ADDR2)           |
    |                                                                                             |
    | 0000     | 1000   | gt    ADDR1, VALUE   | status flag = ADDR1 > ADDR2                      |
    | 0001     | 1000   | gt    ADDR1, ADDR2   | status flag = ADDR1 > (value of ADDR2)           |
    |                                                                                             |
    |          | 1101   | iret                 | return from interrupt                            |
    |                                                                                             |
    | 0000     | 1110   | in     VALUE         | OUT = read port number specified by VALUE        |
    | 0001     | 1110   | inp    ADDR1         | OUT = read port number specified in ADDR1        |
    |                                                                                             |
    | 0000     | 1111   | out    ADDR1, VALUE  | write value in ADDR1 to port specified by VALUE  |
    | 0001     | 1111   | outp   ADDR1, ADDR2  | write value in ADDR1 to port specified in ADDR2  |
    
### "Missing" opcodes

    not ADDR1
        nand ADDR1, ADDR1

    and ADDR1, VALUE
        nand ADDR1, VALUE
        nand OUT, OUT # NOT OUT

    or ADDR1, VALUE
        movp  REG1, ADDR1
        mov   REG2, VALUE
        nandp REG1, REG1
        movp  REG1, OUT
        nandp REG2, REG2
        movp  REG2, OUT
        nandp REG1, REG2

    jmp ADDR1
        mov FLAGS, 0b00000010 # Set zero flag.
        jz ADDR1              # Jump if zero flag is set.

    sub ADDR1, ADDR2
        nand ADDR2, ADDR2   # NOT <value of ADDR2>
        add OUT, 1          # 2's compliment (negate, add 1 to subtract)
        addp ADDR1, OUT     # ADD <value of ADDR1>

    eq ADDR1, ADDR2 # Compare two addresses.
    je ADDR3       # Then jump to the third if they're not equal.
        # Subtract ADDR2 from ADDR1
            nand ADDR2, ADDR2 # NOT <value of ADDR2>
            add OUT, 1        # 2's compliment (negate, add 1 to subtract)
            addp ADDR1, OUT   # ADD <value of ADDR1>
        # At this point, the zero flag is set to 0 if they're equal.
        jz ADDR3 # Jump if equal.
