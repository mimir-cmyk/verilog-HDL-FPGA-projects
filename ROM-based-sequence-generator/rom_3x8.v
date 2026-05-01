module rom_3x8 (
    input  [2:0] addr,     //3-bit address, which acts as selector
    output reg [7:0] data  //8 bit output
);

always @(*) begin //combinational, output changes immediately when input does 
    case (addr) //used the example mapping
        3'b000: data = 8'b00000001; //1
        3'b001: data = 8'b00001000; //8
        3'b010: data = 8'b00010000; //16
        3'b011: data = 8'b00011000; //24
        3'b100: data = 8'b00100000; //32
        3'b101: data = 8'b00101000; //40
        3'b110: data = 8'b00110000; //48
        3'b111: data = 8'b01000000; //64
        default: data = 8'b00000000;
    endcase
end

endmodule
