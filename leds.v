// Led binary counter
// Santiago Ignacio Betelu
module basys3_leds_demo(
    input  clk,         // 100 MHz system clock
    output [15:0] led   // leds
    );
       
    reg [21:0] refresh_clk_counter = 0;
    reg [15:0] binary_count = 0; // main counter
    
    always @(posedge clk) begin
        refresh_clk_counter <= refresh_clk_counter + 1; // period 2^22       
        if(refresh_clk_counter==0) begin
             binary_count <= binary_count + 1;  // period 2^16
        end
    end
    
    assign led = binary_count[15:0];

endmodule

    
