
// PROGRAM FLOW (16 instructions):
//
//  [0]  lw  $s0, 0x00($zero)     load current_temp
//  [1]  lw  $s1, 0x04($zero)     load desired_temp
//  [2]  lw  $s2, 0x08($zero)     load critical_temp
//  [3]  addi $s3, $zero, 1       constant 1  (ON)
//  [4]  addi $s4, $zero, 0       constant 0  (OFF)
//
//   FAN LOGIC 
//  [5]  slt  $t0, $s1, $s0       t0 = (desired < current) ? 1 : 0
//  [6]  bne  $t0, $zero, +2      if t0!=0 jump to [9] FAN_ON
//  [7]  sw   $s4, 0x0C($zero)    FAN_OFF: write 0 to 0x0C
//  [8]  j    10                  skip FAN_ON, jump to [10]
//  [9]  sw   $s3, 0x0C($zero)    FAN_ON:  write 1 to 0x0C

//   ALARM LOGIC 
//  [10] slt  $t1, $s2, $s0    t1 = (critical < current) ? 1 : 0
//  [11] bne  $t1, $zero, +2   if t1!=0 jump to [14] ALARM_ON
//  [12] sw   $s4, 0x10($zero)    ALARM_OFF: write 0 to 0x10
//  [13] j    0       loop back to [0]
//  [14] sw   $s3, 0x10($zero)    ALARM_ON:  write 1 to 0x10
//  [15] j    0     loop back to [0]

// Branch/jump targets:
//   mem[6]  bne offset=+2 - PC+4=28, target=36=mem[9]   
//   mem[8]  j 10 - byte addr 40  = mem[10]      
//   mem[11] bne offset=+2 - PC+4=48, target=56=mem[14]  
//   mem[13] j 0 - byte addr 0   = mem[0]       
//   mem[15] j 0 - byte addr 0   = mem[0]       

// Register map:
//   $zero=r0  $t0=r8  $t1=r9
//   $s0=r16 (current)  $s1=r17 (desired)  $s2=r18 (critical)
//   $s3=r19 (const 1)  $s4=r20 (const 0)
// ============================================================
module instruction_memory(
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] mem [0:63];

    initial begin

        // lw $s0, 0x00($zero)
        mem[0]  = 32'b100011_00000_10000_0000000000000000;

        //  lw $s1, 0x04($zero)
        mem[1]  = 32'b100011_00000_10001_0000000000000100;

        //  lw $s2, 0x08($zero)
        mem[2]  = 32'b100011_00000_10010_0000000000001000;

        //  addi $s3, $zero, 1
        mem[3]  = 32'b001000_00000_10011_0000000000000001;

        // addi $s4, $zero, 0
        mem[4]  = 32'b001000_00000_10100_0000000000000000;

        // slt $t0, $s1, $s0   (t0=1 if desired < current)
        mem[5]  = 32'b000000_10001_10000_01000_00000_101010;

        // bne $t0, $zero, +2  - if t0!=0 goto mem[9] FAN_ON
        mem[6]  = 32'b000101_01000_00000_0000000000000010;

        // sw $s4, 0x0C($zero) - FAN_OFF: fan_reg = 0
        mem[7]  = 32'b101011_00000_10100_0000000000001100;

        // j 10  — skip over FAN_ON, continue to alarm logic
        mem[8]  = 32'b000010_00000000000000000000001010;

        //  sw $s3, 0x0C($zero) — FAN_ON: fan_reg = 1  - bne[6] lands here
        mem[9]  = 32'b101011_00000_10011_0000000000001100;

        //  slt $t1, $s2, $s0  (t1=1 if critical < current)
        mem[10] = 32'b000000_10010_10000_01001_00000_101010;

        //  bne $t1, $zero, +2 - if t1!=0 goto mem[14] ALARM_ON
        mem[11] = 32'b000101_01001_00000_0000000000000010;

        //  sw $s4, 0x10($zero) - ALARM_OFF: alarm_reg = 0
        mem[12] = 32'b101011_00000_10100_0000000000010000;

        //  j 0 — loop back
        mem[13] = 32'b000010_00000000000000000000000000;

        //  sw $s3, 0x10($zero) — ALARM_ON: alarm_reg = 1  ← bne[11] lands here
        mem[14] = 32'b101011_00000_10011_0000000000010000;

        //  j 0 -    loop back
        mem[15] = 32'b000010_00000000000000000000000000;

        // NOP padding
        begin : fill_nop
            integer idx;
            for (idx = 16; idx < 64; idx = idx + 1)
                mem[idx] = 32'b001000_00000_00000_0000000000000000;
        end

    end

    assign instruction = mem[address[7:2]];

endmodule
