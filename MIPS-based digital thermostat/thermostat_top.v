module thermostat_top(
    input  wire clk,
    input  wire  reset,
    input  wire  btn_load,
    input  wire [7:0] sw_temp,
    output wire  fan,
    output wire  alarm,
    output wire [7:0] LED
);

    
    // BTN1 DEBOUNCER
    reg [19:0] deb_cnt;
    reg btn_stable;
    reg  btn_prev;
    wire  btn_posedge;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            deb_cnt    <= 20'd0;
            btn_stable <= 1'b0;
            btn_prev   <= 1'b0;
        end else begin
            if (btn_load == btn_stable) begin
                deb_cnt <= 20'd0;
            end else begin
                deb_cnt <= deb_cnt + 1'b1;
                if (deb_cnt == 20'hFFFFF) begin
                    btn_stable <= btn_load;
                    deb_cnt    <= 20'd0;
                end
            end
            btn_prev <= btn_stable;
        end
    end

    assign btn_posedge = btn_stable & ~btn_prev;

 
    // TEMPERATURE LATCH
    reg [7:0] temp_latch;

    always @(posedge clk or posedge reset) begin
        if (reset)
            temp_latch <= 8'd0;
        else if (btn_posedge)
            temp_latch <= sw_temp;
    end

    
    // INSTRUCTION FETCH
    wire [31:0] pc;
    wire [31:0] instruction;

    instruction_memory IM (
        .address(pc),
        .instruction(instruction)
    );

    
    // DECODE FIELDS
    
    wire [5:0]  opcode = instruction[31:26];
    wire [4:0]  rs = instruction[25:21];
    wire [4:0]  rt= instruction[20:16];
    wire [4:0]  rd = instruction[15:11];
    wire [5:0]  funct  = instruction[5:0];
    wire [15:0] imm16 = instruction[15:0];

    wire [31:0] sign_imm;
    sign_extend SE (
        .in (imm16),
        .out(sign_imm)
    );

    
    // CONTROL UNIT
   
    wire reg_write, mem_read, mem_write;
    wire alu_src, reg_dst, branch, bne_flag, jump;
    wire [3:0]  alu_op;

    control_unit CU (
        .opcode (opcode),
        .funct (funct),
        .reg_write(reg_write),
        .mem_read (mem_read),
        .mem_write(mem_write),
        .alu_src  (alu_src),
        .reg_dst (reg_dst),
        .branch (branch),
        .bne_flag (bne_flag),
        .jump (jump),
        .alu_op(alu_op)
    );

    
    // REG DESTINATION MUX
    
    wire [4:0] write_reg = reg_dst ? rd : rt;

    
    // REGISTER FILE
    
    wire [31:0] rd1, rd2, write_back;

    register_file RF (
        .clk(clk),
        .reset(reset),
        .rs(rs),
        .rt(rt),
        .rd(write_reg),
        .wd(write_back),
        .reg_write(reg_write),
        .rd1(rd1),
        .rd2(rd2)
    );

    // ALU
    
    wire [31:0] alu_in2 = alu_src ? sign_imm : rd2;
    wire [31:0] alu_result;
    wire zero;

    alu ALU (
        .a(rd1),
        .b(alu_in2),
        .alu_op (alu_op),
        .result (alu_result),
        .zero(zero)
    );

    // DATA MEMORY
    wire [31:0] mem_data_raw;

    data_memory DM (
        .clk(clk),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .address (alu_result),
        .write_data(rd2),
        .read_data (mem_data_raw),
        .fan(fan),
        .alarm(alarm)
    );

    // temp_latch INTERCEPT for address 0x00
    
    wire reading_temp = mem_read && (alu_result == 32'h00000000);

    wire [31:0] mem_data = reading_temp
                           ? {24'b0, temp_latch}
                           : mem_data_raw;

    // WRITE-BACK MUX
    
    assign write_back = mem_read ? mem_data : alu_result;

    // BRANCH / PC LOGIC
    wire branch_taken = branch & (bne_flag ? ~zero : zero);

    wire [31:0] pc_plus4      = pc + 32'd4;
    wire [31:0] branch_target = pc_plus4 + {sign_imm[29:0], 2'b00};
    wire [31:0] jump_target   = {pc_plus4[31:28], instruction[25:0], 2'b00};

    wire [31:0] pc_next =
        jump         ? jump_target   :
        branch_taken ? branch_target :
                       pc_plus4;

    program_counter PC_REG (
        .clk    (clk),
        .reset  (reset),
        .pc_next(pc_next),
        .pc     (pc)
    );

    // LED OUTPUTS
    
    assign LED[0] = fan;
    assign LED[1] = alarm;
    assign LED[7:2] = temp_latch[5:0];

endmodule
