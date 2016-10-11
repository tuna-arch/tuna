# Tuna Instruction Set Architecture

See [README.md](https://github.com/tuna-arch/tuna/blob/master/README.md)
for a more high-level discussion of the architecture.

Written by [Ellen Dash](http://puppy.technology).

The latest version of this document can be found at https://github.com/tuna-arch/tuna/blob/master/2_isa.md.

[Tuna Instruction Set Architecture](https://github.com/tuna-arch/tuna/blob/master/2_isa.md) by [Ellen Dash](http://puppy.technology) is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

## System Architecture

The system has a designated register size &mdash; also known as the `WORD` size. This can be e.g. 8-bit, 16-bit, 32-bit, etc. The register size determines amount of addressable RAM, because it determines the largest address that can be referenced.

E.g.,

* 8-bit registers can store addresses 0x0 to 0xFF (256 bytes of RAM),
* 16-bit registers can store addresses 0x0 to 0xFFFF (approximately 65 kilobytes of RAM),
* 32-bit registers can store addresses 0x0 to 0xFFFFFFFF (approximately 4 gigabytes of RAM).

**_Word size is distinct from how much RAM the system actually has._**

### Registers

Each register is one word wide.

E.g.,

* on 8-bit systems the registers are 0x0, 0x1, 0x2, etc;
* on 16-bit systems they would be 0x0, 0x2, 0x4, etc;
* on 32-bit systems they would be 0x0, 0x4, 0x8, etc.

| Register name | Memory address           | Purpose |
|---------------|--------------------------|-------------------
| OUT           | 0x0 * WORD size in bytes | Contains results for non-destructive operations (undefined otherwise).           |
| FLAGS         | 0x1 * WORD size in bytes | Contains information about the last ALU operation (undefined after non-ALU ops). |
| r1            | 0x2 * WORD size in bytes | General purpose register.                                                        |
| r2            | 0x3 * WORD size in bytes | General purpose register.                                                        |
| r3            | 0x4 * WORD size in bytes | General purpose register.                                                        |
| r4            | 0x5 * WORD size in bytes | General purpose register.                                                        |
| r5            | 0x6 * WORD size in bytes | General purpose register.                                                        |
| r6            | 0x7 * WORD size in bytes | General purpose register.                                                        |
| r7            | 0x8 * WORD size in bytes | General purpose register.                                                        |

Since registers are just a chunk of RAM, there is no hardware implications for this &mdash; only software implications. See [#Booting](#Booting) for details.

The `FLAGS` register stores information from the output of the last ALU operation:

| bit # | name   | value                                  |
|-------|--------|----------------------------------------|
| ---x  | carry  | 1 if carry required                    |
| --x-  | zero   | 1 if last instruction equated to zero  |
| rest  |        | reserved                               |


All commands are formatted as follows, with unused operands set to zero:

    [WORD-sized opcode][WORD-sized operand][WORD-sized operand]

The last 4 bits of the opcode determine the actual operation. The rest are modifiers.

Modifiers, truncated to 4 bits for brevity (since all of the bits before that are also reserved):

| bit   | name    | purpose   |
|-------|---------|-----------|
| x---  |         | reserved  |
| -x--  |         | reserved  |
| --x-  |         | reserved  |
| ---x  | pointer | designates whether the operand is an address to retrieve the value from. 0 = value, 1 = pointer. |

### Opcodes/operands and what they do

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

#### "Missing" opcodes

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

### Booting

The entire hardware initialization consists of:

* A implementation-specific method for loading the initial program into memory at address 0x0.
* Setting the Program Counter to 0 (zero).
* Beginning to fetch and execute instructions.

The fact that the first 9 words of RAM are used as registers means the initial program the computer loads should function even if those values change, which can be achieved with the following:

```
mov FLAGS, 0b00000010 # Set zero flag.               (Location of registers 0-2.)
jz 0x9 * WORD_SIZE    # Jump to after the registers. (Location of registers 3-5.)
mov OUT, OUT          # No-op.                       (Location of registers 5-8.)
```

This reserves space for OUT, FLAGS, and 7 general-purpose registers.
