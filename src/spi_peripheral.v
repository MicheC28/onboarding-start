/*

module: 

en output for uo 
en output for uio
en pwm on uo 
en pwm on uio
pwm duty cycle

inputs:
- /cs
- serial clk
-COPI 

16 bit input serial




*/


module spi_peripheral (
    input wire clk,
    input wire sclk,
    input wire rst_n,
    input wire ncs,
    input wire COPI,

    output reg [7:0] en_out_uo,
    output reg [15:8] en_out_uio,
    output reg [7:0] en_pwm_uo,
    output reg [15:8] en_pwm_uio,
    output reg [7:0] pwm_duty_cycle
);

//shift register to take in 16 bit serial 
// update reg accordingly

reg [15:0] shift_reg;
reg [3:0] bit_count;

always_ff @(posedge clk)begin
    if(rst_n == 0) begin
        
        en_out_uo <= 'd0;
        en_out_uio <= 'd0;
        en_pwm_uo <= 'd0;
        en_pwm_uio <= 'd0;
        pwm_duty_cycle <= 'd0;

        bit_count <= 'd0;
        shift_reg <= 'd0;
    end
end

always_ff @(posedge sclk) begin
    if(!ncs && bit_count < 16) begin
        shift_reg <= {shift_reg[14:0], COPI};  // Left shift, new bit at LSB
        bit_count <= bit_count + 1;
    end

    else begin
        shift_reg <= shift_reg; 
        bit_count <= bit_count;
    end
end


always_ff @(posedge ncs) begin
    if(bit_count == 16 && shift_reg[15] == 1) begin
        //check valid address
        //may have to flip order

        case(shift_reg[14:7])
            2'h00: begin
                en_out_uo <= shift_reg[7:0];
            end

            2'h01: begin
                en_out_uio <= shift_reg[7:0];
            end

            2'h02: begin
                en_pwm_uo <= shift_reg[7:0];
            end

            2'h03: begin
                en_pwm_uio <= shift_reg[7:0];
            end

            2'h04: begin
                pwm_duty_cycle <= shift_reg[7:0];
            end

            default: begin
            end
        endcase

        bit_count <= 'd0; // reset bit count for next transaction

     
    end
end






endmodule