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
    output reg [7:0] en_out_uio,
    output reg [7:0] en_pwm_uo,
    output reg [7:0] en_pwm_uio,
    output reg [7:0] pwm_duty_cycle
);

// n -> cdc[0] -> cdc[1] -> ...

reg [1:0] cdc_sclk;
reg [1:0] cdc_ncs;
reg [1:0] cdc_copi;

wire sclk_rising_edge = (cdc_sclk[1] == 0) && (cdc_sclk[0] == 1);
wire ncs_rising_edge = (cdc_ncs[1] == 0) && (cdc_ncs[0] == 1);

reg [15:0] shift_reg;
reg [4:0] bit_count;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 0) begin
        
        en_out_uo <= 'd0;
        en_out_uio <= 'd0;
        en_pwm_uo <= 'd0;
        en_pwm_uio <= 'd0;
        pwm_duty_cycle <= 'd0;

        bit_count <= 'd0;
        shift_reg <= 'd0;

        cdc_sclk <= 2'b00;
        cdc_ncs <= 2'b11;
        cdc_copi <= 2'b00;
    end
    else begin
        if(sclk_rising_edge && !cdc_ncs[1]) begin
            if( bit_count < 16) begin
                shift_reg <= {shift_reg[14:0], cdc_copi[1]};  // Left shift, new bit at LSB
                bit_count <= bit_count + 1;
            end

            else begin
                shift_reg <= shift_reg; 
                bit_count <= bit_count;
            end
        end 

        else if(ncs_rising_edge && bit_count == 16 && shift_reg[15] == 1) begin

        case(shift_reg[14:8])
            7'b0000000: begin
                en_out_uo <= shift_reg[7:0];
            end

            7'b0000001: begin
                en_out_uio <= shift_reg[7:0];
            end

            7'b0000010: begin
                en_pwm_uo <= shift_reg[7:0];
            end

            7'b0000011: begin
                en_pwm_uio <= shift_reg[7:0];
            end

            7'b0000100: begin
                pwm_duty_cycle <= shift_reg[7:0];
            end

            default: begin
            end
        endcase

        bit_count <= 'd0; // reset bit count for next transaction     
        end

        cdc_sclk <= {cdc_sclk[0], sclk};
        cdc_ncs <= {cdc_ncs[0], ncs};
        cdc_copi <= {cdc_copi[0], COPI};
    end
end

endmodule