# Kalkulu

## Registers

Each 1-byte (8-bit) chunk of RAM is treated as a register.

* 0x0 (the first byte) is reserved as the `OUT` register, which contains the results for any non-destructive operations (undefined otherwise).
* 0x1 (the second byte) is reserved as the `FLAGS` register, which stores information about the last ALU operation (undefined for non-ALU operations).
* 0x2-0x8 should treated as registers (r1-r7). Since registers are just a chunk of RAM, there is no hardware implications for this &mdash; only software implications. See [#Booting](#Booting) for details.

The `FLAGS` register stores information from the output of the last instruction:

| bit #      | name   | value                                  |
|------------|--------|----------------------------------------|
| ---- ---x  | carry  | 1 if carry required                    |
| ---- --x-  | zero   | 1 if last instruction equated to zero  |
| rest       |        | reserved                               |


All commands are formatted as follows, with unused operands set to zero:

    [8-bit opcode][8-bit operand][8-bit operand]

The first four bits of the opcode are modifiers, the second four bits are the actual opcode.

Modifiers:

| bit   | name    | purpose   |
|-------|---------|-----------|
| x---  |         | reserved  |
| -x--  |         | reserved  |
| --x-  |         | reserved  |
| ---x  | pointer | designates whether the operand is an address to retrieve the value from. 0 = value, 1 = pointer. |

## Opcodes/operands and what they do

Each opcode only requires one implementation; the Pointer modifier changes the behavior of the fetcher stage, and is completely transparent to the rest of the system. The general layout is `opcode destination, source_or_value`.

| Modifier | Opcode | Operand              | Expression                                       |
|----------|--------|----------------------|--------------------------------------------------|
| 0000     | 0000   | mov   ADDR1, VALUE   | ADDR1 = VALUE                                    |
| 0001     | 0000   | movp  ADDR1, ADDR2   | ADDR1 = value of ADDR2                           |
|          |        |                      |                                                  |
| 0000     | 0001   | add   ADDR1, VALUE   | OUT = ADDR1 + VALUE                              |
| 0001     | 0001   | addp  ADDR1, ADDR2   | OUT = ADDR1 + value of ADDR2                     |
|          |        |                      |                                                  |
| 0000     | 0010   | nand  ADDR1, VALUE   | OUT = ADDR1 nand VALUE                           |
| 0001     | 0010   | nandp ADDR1, ADDR2   | OUT = ADDR1 nand (value of ADDR2)                |
|          |        |                      |                                                  |
| 0000     | 0011   | shl   ADDR1, VALUE   | OUT = ADDR1 << VALUE                             |
| 0001     | 0011   | shlp  ADDR1, ADDR2   | OUT = ADDR1 << (value of ADDR2)                  |
|          |        |                      |                                                  |
| 0000     | 0100   | shr   ADDR1, VALUE   | OUT = ADDR2 >> VALUE                             |
| 0001     | 0100   | shrp  ADDR1, ADDR2   | OUT = ADDR2 >> (value of ADDR2)                  |
|          |        |                      |                                                  |
|          | 0101   | jz    ADDR1          | jump to ADDR1 if zero flag is set                |
|          |        |                      |                                                  |
| 0000     | 0110   | lt    ADDR1, VALUE   | status flag = ADDR1 < ADDR2                      |
| 0001     | 0110   | lt    ADDR1, ADDR2   | status flag = ADDR1 < (value of ADDR2)           |
|          |        |                      |                                                  |
| 0000     | 0111   | gt    ADDR1, VALUE   | status flag = ADDR1 > ADDR2                      |
| 0001     | 0111   | gt    ADDR1, ADDR2   | status flag = ADDR1 > (value of ADDR2)           |
|          |        |                      |                                                  |
|          |        |                      |                                                  |
| 0000     | 1110   | in     VALUE         | OUT = read port number specified by VALUE        |
| 0001     | 1110   | inp    ADDR1         | OUT = read port number specified in ADDR1        |
|          |        |                      |                                                  |
| 0000     | 1111   | out    ADDR1, VALUE  | write VALUE to port specified by ADDR1           |
| 0001     | 1111   | outp   ADDR1, ADDR2  | write value in ADDR2 to port specified by ADDR1  |

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
        add OUT, 1          # 2's compliment (negate and add 1 to subtract)
        addp ADDR1, OUT     # ADD <value of ADDR1>

    eq ADDR1, ADDR2 # Compare two addresses.
    je ADDR3       # Then jump to the third if they're not equal.
        # Subtract ADDR2 from ADDR1
            nand ADDR2, ADDR2 # NOT <value of ADDR2>
            add OUT, 1        # 2's compliment (negate and add 1 to subtract)
            addp ADDR1, OUT   # ADD <value of ADDR1>
        # At this point, the zero flag is set to 0 if they're equal.
        jz ADDR3 # Jump if equal.

## Registers and Booting

**The entire hardware initialization sequence is to set the instruction pointer to zero prior to fetching the first instruction.**

With Kalkulu, "registers" are simply assembly shorthands for single-byte chunks of RAM. That is,

| Register name | Memory address |
|---------------|----------------|
| OUT           | 0x0            |
| FLAGS         | 0x1            |
| r1            | 0x2            |
| r2            | 0x3            |
| r3            | 0x4            |
| ...           |                |
| r7            | 0x8            |

However, excluding OUT and FLAGS, there is _no special hardware treatment required for this_. They are simply _assumed_ to be available: the assembler will provide the r1-r7 shorthands, and software will use them as general purpose registers.

The fact that the first 9 bytes of RAM are used for this means the initial program the computer loads should start with the following:

```
mov FLAGS, 0b00000010 # Set zero flag.
jz 0x9                # Jump to 0x9.
mov OUT, OUT          # No-op.
```

This reserves space for OUT, FLAGS, and 7 general-purpose registers.
