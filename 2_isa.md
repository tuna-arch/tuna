# Tuna Instruction Set Architecture

See [README.md](https://github.com/tuna-arch/tuna/blob/master/README.md)
for a more high-level discussion of the architecture.

Written by [Ellen Dash](http://puppy.technology).

The latest version of this document can be found at https://github.com/tuna-arch/tuna/blob/master/2_isa.md.

[Tuna Instruction Set Architecture](https://github.com/tuna-arch/tuna/blob/master/2_isa.md) by [Ellen Dash](http://puppy.technology) is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

## System Architecture

The system has a designated register size &mdash; also known as the word size. It must be 16 bits or larger. This can be e.g. 16-bit, 32-bit, etc. The register size determines amount of addressable RAM, because it determines the largest address that can be referenced.

E.g.,

* 8-bit registers can store addresses 0x0 to 0xFF (256 bytes of RAM),
* 16-bit registers can store addresses 0x0 to 0xFFFF (approximately 65 kilobytes of RAM),
* 32-bit registers can store addresses 0x0 to 0xFFFFFFFF (approximately 4 gigabytes of RAM).

**_Word size is distinct from how much RAM the system actually has._**

For the rest of the document, and in the assembler, `WORD_SIZE` is defined as the word size in bytes.

Values are stored as big endian.

### Registers

Each register is one word wide.

E.g.,

* on 16-bit systems they would be 0x0, 0x2, 0x4, etc;
* on 32-bit systems they would be 0x0, 0x4, 0x8, etc.


| Register name | Purpose                                                                                 |
|---------------|-----------------------------------------------------------------------------------------|
| r0 (OUT)      | Contains results for non-destructive operations (unchanged otherwise).                  |
| r1 (FLAGS)    | Contains information about the last ALU operation (not modified by non-ALU operations). |
| r2            | General purpose register.                                                               |
| r3            | General purpose register.                                                               |
| r4            | General purpose register.                                                               |
| r5            | General purpose register.                                                               |
| r6            | General purpose register.                                                               |
| r7            | General purpose register.                                                               |
| r8            | General purpose register.                                                               |

The `FLAGS` register stores information from the output of the last ALU operation:

| bit # | name   | value                                  |
|-------|--------|----------------------------------------|
| ---x  | carry  | 1 if carry required                    |
| --x-  | zero   | 1 if last instruction equated to zero  |
| rest  |        | reserved                               |


All commands are formatted as follows, with unused operands set to zero:

    [Immediate Modifier][Opcode][WORD-sized Operand][WORD-sized Operand]

The Immediate Modifier affects the behavior of the fetcher stage, and is completely transparent to the rest of the system. If it is 1, the last operand is treated as a value. If it is 0, the last operand is treated as a reference to a register.

### Opcodes/operands and what they do

Each opcode only requires one implementation; the Immediate Modifier changes the behavior of the fetcher stage, and is completely transparent to the rest of the system. The general layout is `opcode destination, source_or_value`.

| Opcode | Example              | Expression                                                             |
|--------|----------------------|------------------------------------------------------------------------|
| 0000   | store REG1, VALUE    | Store the value stored in REG2 into the memory address stored in REG1. |
| 0001   | load  REG1, REG2     | Load the value of REG1 into REG1.  ???? NOT SURE IF THIS MAKES SENSE.  |
| 0010   | mov   REG1, REG2     | Copy the value of REG2 to REG1.                                        |
| 0011   | nand  REG1, REG2     | OUT = (value of REG1) nand (value of REG2)                             |
| 0100   | shl   REG1, REG2     | OUT = (value of REG1) << (value of REG2)                               |
| 0101   | shr   REG1, REG2     | OUT = (value of REG1) >> (value of REG2)                               |
| 0110   | jz    REG1           | jump to the memory address stored in REG1 if zero flag is set.         |
| 0111   | lt    REG1, REG2     | status flag = 1 if ADDR1 < ADDR2, 0 otherwise.                         |
| 1000   | gt    REG1, REG2     | status flag = 1 if ADDR1 > ADDR2, 0 otherwise.                         |
| | | TODO: FIGURE OUT I/O. |
| 1110   | in     VALUE         | OUT = read port number specified by VALUE        |
| 1111   | out    ADDR1, VALUE  | write VALUE to port specified by ADDR1           |

#### "Missing" opcodes

These should be macros (or similar) offered by the assembler/compiler, for convenience purposes.

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

    jmp REG1
        mov FLAGS, 0b00000010 # Set zero flag.
        jz REG1               # Jump if zero flag is set.

    sub ADDR1, ADDR2
        nand ADDR2, ADDR2   # NOT <value of ADDR2>
        add OUT, 1          # 2's compliment (negate and add 1 to subtract)
        addp ADDR1, OUT     # ADD <value of ADDR1>

    eq REG1, REG2 # Compare two addresses.
    je REG3        # Then jump to the third if they're not equal.
        # Subtract REG2 from REG2.
            nand REG2, REG2 # NOT <value of ADDR2>
            add  OUT,  1    # 2's compliment (negate and add 1 to subtract)
            add  REG1, OUT  # ADD <value of ADDR1>
        # At this point, the zero flag is set to 0 if they're equal.
        jz REG3 # Jump if equal.

### Booting

The entire hardware initialization consists of:

* An implementation-specific method for loading the initial program into memory at address 0x0.
* Setting the Program Counter to 0 (zero).
* Beginning to fetch and execute instructions.

Note: Registers won't be zeroed out at boot time.
