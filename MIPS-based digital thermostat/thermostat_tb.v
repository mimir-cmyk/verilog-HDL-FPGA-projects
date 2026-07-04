module thermostat_tb;

    reg clk;
    reg reset;
    reg btn_load;
    reg  [7:0] sw_temp;
    wire fan;
    wire alarm;
    wire [7:0] LED;

    thermostat_top DUT (
        .clk (clk),
        .reset(reset),
        .btn_load(btn_load),
        .sw_temp (sw_temp),
        .fan(fan),
        .alarm (alarm),
        .LED(LED)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task run_cycles;
        input integer n;
        begin
            repeat(n) @(posedge clk);
            #1;
        end
    endtask

    task run_program;
        begin
            run_cycles(40);
        end
    endtask
    // Simulate BTN1 press: hold long enough to pass 20-bit debounce counter
    task press_btn_load;
    begin
        //  press 
        btn_load = 1;
        force DUT.deb_cnt = 20'hFFFFE;   // one tick before threshold
        #1;
        release DUT.deb_cnt;
        run_cycles(3);   // edge1: ->FFFFF, edge2: rollover, stable=1
                          // edge3: temp_latch captures sw_temp

        // release 
        btn_load = 0;
        force DUT.deb_cnt = 20'hFFFFE;
        #1;
        release DUT.deb_cnt;
        run_cycles(2);   // edge1: ->FFFFF, edge2: rollover, stable=0
    end
endtask

    task set_and_check;
        input [7:0] temp;
        input [80*8-1:0] label;
        input exp_fan;
        input exp_alarm;
        begin
            sw_temp = temp;
            press_btn_load;
            run_program;
            if (fan === exp_fan && alarm === exp_alarm) begin
                $display("[PASS] %0s | fan=%b alarm=%b", label, fan, alarm);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s | got fan=%b alarm=%b | exp fan=%b alarm=%b",
                          label, fan, alarm, exp_fan, exp_alarm);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task check;
        input [80*8-1:0] label;
        input exp_fan;
        input exp_alarm;
        begin
            if (fan === exp_fan && alarm === exp_alarm) begin
                $display("[PASS] %0s | fan=%b alarm=%b", label, fan, alarm);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s | got fan=%b alarm=%b | exp fan=%b alarm=%b",
                          label, fan, alarm, exp_fan, exp_alarm);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("============================================");
        $display(" MIPS Digital Thermostat – Testbench");
        $display("============================================");

        btn_load = 0;
        reset  = 1;
        sw_temp  = 8'd0;
        run_cycles(4);
        reset = 0;

        // GROUP 1 – Normal operation (fan=0 alarm=0)
        // desired=25 critical=40 (data_memory initial block)
        
        $display("\n-- Group 1: Normal Operation --");
        set_and_check(8'd22, "T01 22C       ", 0, 0);
        set_and_check(8'd24, "T02 24C       ", 0, 0);
        set_and_check(8'd25, "T03 25C equal ", 0, 0);
        set_and_check(8'd0,  "T04 0C min    ", 0, 0);
        set_and_check(8'd20, "T05 20C       ", 0, 0);

        // GROUP 2 – Cooling activation (fan=1 alarm=0)
        
        $display("\n-- Group 2: Cooling Activation --");
        set_and_check(8'd26,  "T06 26C       ", 1, 0);
        set_and_check(8'd30,  "T07 30C       ", 1, 0);
        set_and_check(8'd35,  "T08 35C       ", 1, 0);
        set_and_check(8'd39,  "T09 39C       ", 1, 0);
        set_and_check(8'd40,  "T10 40C equal ", 1, 0);

        // GROUP 3 – Alarm activation (fan=1 alarm=1)
        
        $display("\n-- Group 3: Alarm Activation --");
        set_and_check(8'd41,  "T11 41C       ", 1, 1);
        set_and_check(8'd45,  "T12 45C       ", 1, 1);
        set_and_check(8'd60,  "T13 60C       ", 1, 1);
        set_and_check(8'd100, "T14 100C      ", 1, 1);
        set_and_check(8'd255, "T15 255C max  ", 1, 1);

        // GROUP 4 – Dynamic transitions
        $display("\n-- Group 4: Dynamic Transitions --");
        set_and_check(8'd30, "T16a 30C up   ", 1, 0);
        set_and_check(8'd20, "T16b 20C down ", 0, 0);
        set_and_check(8'd50, "T17a 50C up   ", 1, 1);
        set_and_check(8'd35, "T17b 35C down ", 1, 0);
        set_and_check(8'd50, "T18a 50C up   ", 1, 1);
        set_and_check(8'd22, "T18b 22C down ", 0, 0);
        set_and_check(8'd25, "T19a osc 25   ", 0, 0);
        set_and_check(8'd26, "T19b osc 26   ", 1, 0);

        
        // GROUP 5 – Instruction coverage
        
        $display("\n-- Group 5: Instruction Coverage --");
        set_and_check(8'd30, "T21 lw ok     ", 1, 0);
        set_and_check(8'd45, "T22 sw ok     ", 1, 1);
        set_and_check(8'd25, "T23 slt bnd   ", 0, 0);
        set_and_check(8'd26, "T24 bne taken ", 1, 0);

        sw_temp = 8'd30;
        press_btn_load;
        run_cycles(200);
        check("T25 j loop    ", 1, 0);

        // Short BTN1 pulse - should NOT latch (debounce test)
        sw_temp  = 8'd22;
        btn_load = 1;
        run_cycles(10);
        btn_load = 0;
        run_cycles(10);
        run_program;
        check("T26 deb short ", 1, 0);

        // Reset mid-operation
        sw_temp = 8'd50;
        press_btn_load;
        run_program;
        reset = 1; run_cycles(4); reset = 0;
        run_program;
        check("T27 reset     ", 0, 0);

        
        $display("\n============================================");
        $display(" RESULTS: %0d PASSED, %0d FAILED (of %0d)",
                  pass_count, fail_count, pass_count+fail_count);
        $display("============================================");
        if (fail_count == 0)
            $display(" ALL TESTS PASSED");
        else
            $display(" SOME TESTS FAILED – check waveforms");

        $finish;
    end

    initial begin
        $dumpfile("thermostat_tb.vcd");
        $dumpvars(0, thermostat_tb);
    end

endmodule
