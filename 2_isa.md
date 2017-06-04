# Tuna Instruction Set Architecture

See [README.md](https://github.com/tuna-arch/tuna/blob/master/README.md)
for a more high-level discussion of the architecture.

Written by [Ellen Dash](http://puppy.technology).

The latest version of this document can be found at https://github.com/tuna-arch/tuna/blob/master/2_isa.md.

[Tuna Instruction Set Architecture](https://github.com/tuna-arch/tuna/blob/master/2_isa.md) by [Ellen Dash](http://puppy.technology) is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

## System Architecture

The system has a designated register size &mdash; also known as the word size. It must be 16 bits or larger. This can be e.g. 16-bit, 32-bit, etc.

TODO: Investigate memory segmentation and such.

**_Word size is distinct from how much RAM the system actually has._**

For the rest of the document, and in the assembler, `WORD_SIZE` is defined as the word size in bytes.

Values are stored as big endian.

### Registers

Each register is one word wide.

TODO: Investiage implications memory segmentation, if I add it, and such has on register layout.
TODO: Determine how many registers would actually be necessary for this ISA to not be a piece of shit. 

| Register name | Purpose                                                                                 |
|---------------|-----------------------------------------------------------------------------------------|
| OUT    (r0)   | Contains results for non-destructive operations (undefined otherwise).                  |
| FLAGS  (r1)   | Contains information about the last ALU operation (undefined after non-ALU operations). |
| r2            | General purpose register.                                                               |
| r3            | General purpose register.                                                               |
| r4            | General purpose register.                                                               |
| r5            | General purpose register.                                                               |
| r6            | General purpose register.                                                               |
| r7            | General purpose register.                                                               |

TODO: Determine if registers should be set to any specific value at boot, or if we can bullshit it and set everything manually in software.

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

The general layout is `opcode destination, source_or_value`.

| Opcode | Example              | Expression                                       |
|--------|----------------------|--------------------------------------------------|
| 0001   | loadi REG1,  VALUE   | register REG = VALUE
| 0010   | store ADDR1, REG1    | ADDR1 = value of REG1
| 0001   | 
| 0010   | add   REG1, REG2     | 
| 1000   | load  REG1,  ADDR1   | register REG1 = value of ADDR1

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

* An implementation-specific method for loading the initial program into memory at address 0x0.
* Setting the Program Counter to 0 (zero).
* Beginning to fetch and execute instructions.

The fact that the first 9 words of RAM are used as registers means the initial program the computer loads should function even if those values change, which can be achieved with the following:

```
mov FLAGS, 0b00000010 # Set zero flag.               (Location of registers 0-2.)
jz 0x9 * WORD_SIZE    # Jump to after the registers. (Location of registers 3-5.)
mov OUT, OUT          # No-op.                       (Location of registers 5-8.)
```

This reserves space for OUT, FLAGS, and 7 general-purpose registers.
