`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/27 10:06:12
// Design Name: 
// Module Name: replace_police
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//LRU

module replace_police(
        input       wire    [1:0]   used_record,
        input       wire    [1:0]   valid_array,
        
        output      wire    [1:0]   bank_replaced
    );
    
        assign      bank_replaced = valid_array == 2'b00 ? 2'b01
                                    : (valid_array == 2'b10 ? 2'b01
                                    : (valid_array == 2'b01 ? 2'b10
                                    : (used_record == 2'b01 ? 2'b10
                                    : 2'b01)));
endmodule
