# Kalkulu: 4-bit processor design

## Registers

There is one output register, `OUT`, which is used for output of non-destructive operations (addition and subtract, for instance).

There can be up to 14 general-purpose registers addressed by one 4-bit byte (0000 is `OUT`, 0001 - 1111 are `r1` through `r15`).

The first implementation will likely have between 2 and 4.

All commands are given two inputs - `IN1` and `IN2`, which are either registers or binary values depending on the command.
The commands ignore one or both of the inputs (ie, `inc` and `dec` will only use one input register).

For each command it does the following:

1. Read the next four bits from memory into `CMD`
2. Read the next four bits from memory into `IN1`
3. Read the next four bits from memory into `IN2`
4. Raise the `SEND` lead, which tells the system to send the values from `CMD`, `IN1`, `IN2` to the corresponding multiplexers.

The `OUT` register is read-only and stores the output of non-destructive commands (math, such as addition and subtraction).

## Opcodes/operands and what they do

    | Opcode | Operand         | Expression              |
    ======================================================
    | 0000   | movr REG1, REG2 | REG1 = REG2             |
    | 0001   | movv REG1, VAL  | REG1 = VAL              |
    | 0010   | add  REG1, REG2 | OUT  = REG1 + REG2      |
    | 0011   | and  REG1, REG2 | OUT  = REG1 and REG2    |
    | 0100   | or   REG1, REG2 | OUT  = REG1 or  REG2    |
    | 0101   | xor  REG1, REG2 | OUT  = REG1 xor REG2    |
    | 0110   | in   REG1, PORT | REG1 = PORT (i/o ports) |
    | 0111   | out  PORT, REG1 | PORT = REG1 (i/o ports) |
    | 1000   | jmp  REG1       | N/A                     |
    | 1001   | jz   REG1       | jmp if OUT == 0         |
    | 1010   | ls   REG1, VAL  | REG1 = REG1 << VAL      |
    | 1011   | rs   REG1, VAL  | REG1 = REG1 >> VAL      |
