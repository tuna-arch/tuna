# Kalkulu: 4-bit processor design

## Registers

There is one output register, `OUT`, which is used for output of non-destructive operations (addition and subtract, for instance).

There can be up to 14 general-purpose registers addressed by one 4-bit byte (0000 is `OUT`, 0001 - 1111 are `r1` through `r14`).

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

    | Opcode | Operand         | Expression            |
    ====================================================
    | 0000   | nop             | N/A                   |
    | 0001   | hlt             | N/A                   |
    | 0010   | movr REG1, REG2 | REG1 = REG2           |
    | 0011   | movv REG1, VAL  | REG1 = VAL            |
    | 0100   | inc  REG1       | REG1 = REG1 + 1       |
    | 0101   | dec  REG1       | REG1 = REG1 - 1       |
    | 0110   | addr REG1, REG2 | OUT  = REG1 + REG2    |
    | 0111   | addv REG1, VAL  | OUT  = REG1 + VAL     |
    | 1000   | subr REG1, REG2 | OUT  = REG1 - REG2    |
    | 1001   | subv REG1, VAL  | OUT  = REG1 - VAL     |
    | 1010   | cmpr REG1, REG2 | OUT  = (REG1 == REG2) |
    | 1011   | cmpv REG1, VAL  | OUT  = (REG1 == VAL)  |
    | 1100   | jmp  REG1       | N/A                   |
    | 1101   | jo   REG1       | jmp if OUT == 1       |
    | 1110   | jz   REG1       | jmp if OUT == 0       |
