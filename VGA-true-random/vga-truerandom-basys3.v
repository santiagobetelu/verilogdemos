// This module is a demonstration of nondeterministic behaviour in FPGAS. Its implements two ring oscillators
// that cause a race condition, and the xor of the two results is fed into a VGA signal.
// If the program works propertly, you should see snow on the screen
// This version is for the board Basys 3, Artix 7 FPGA.
// Santiago Ignacio Betelu
module vga_true_random (
    input  clk_100mhz,  // Basys 3 onboard 100MHz clock
    output hsync,       // Horizontal Sync
    output vsync,       // Vertical Sync
    output [2:0] vga_red,   // 3-bit Red color component
    output [2:0] vga_green, // 3-bit Green color component
    output [2:0] vga_blue   // 3-bit Blue color component
);

    // Horizontal Timings (pixels)
    localparam H_ACTIVE   = 640; // Visible pixels
    localparam H_FP       = 16;  // Horizontal Front Porch
    localparam H_SYNC     = 96;  // Horizontal Sync Pulse
    localparam H_BP       = 48;  // Horizontal Back Porch
    localparam H_TOTAL    = H_ACTIVE + H_FP + H_SYNC + H_BP; // 800 total pixels
    // Vertical Timings (lines)
    localparam V_ACTIVE   = 480; // Visible lines
    localparam V_FP       = 10;  // Vertical Front Porch
    localparam V_SYNC     = 2;   // Vertical Sync Pulse
    localparam V_BP       = 33;  // Vertical Back Porch
    localparam V_TOTAL    = V_ACTIVE + V_FP + V_SYNC + V_BP; // 525 total lines

    reg clk_25mhz= 0;      // VGA pixel clock output
    reg clk_cnt= 0; // Counter for clock division
    wire x1, y1, z1;
    wire x2, y2, z2;
    wire xorrings;
    
    // --- VGA Controller Registers ---
    reg [9:0] h_count; // Horizontal pixel counter (0 to H_TOTAL-1)
    reg [9:0] v_count; // Vertical line counter (0 to V_TOTAL-1)

    reg r_hsync;      // Registered HSYNC output
    reg r_vsync;      // Registered VSYNC output
    reg r_h_active;   // Flag for horizontal active area
    reg r_v_active;   // Flag for vertical active area
    reg [2:0] r_vga_red;   // Registered Red color output
    reg [2:0] r_vga_green; // Registered Green color output
    reg [2:0] r_vga_blue;  // Registered Blue color output

    // clock for VGA is clk_25mHz
    always @(posedge clk_100mhz) begin
        clk_cnt <= clk_cnt + 1; // Increment counter
        if (clk_cnt==0 ) begin // Period 4
            clk_25mhz<= ~clk_25mhz;   // Toggle the 25MHz clock every 4 ticks          
        end
    end

    // To extract true randomness use 2 ring oscillators
    // Ring Oscillator 1
    (* DONT_TOUCH = "true" *) assign x1 = ~z1;
    (* DONT_TOUCH = "true" *) assign y1 = ~x1;
    (* DONT_TOUCH = "true" *) assign z1 = ~y1;

    // Ring Oscillator 2
    (* DONT_TOUCH = "true" *) assign x2 = ~z2;
    (* DONT_TOUCH = "true" *) assign y2 = ~x2;
    (* DONT_TOUCH = "true" *) assign z2 = ~y2;
    assign xorrings= x1^x2;
    
    // VGA Logic
    always @(posedge clk_25mhz) begin    
        // Horizontal Counter
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0; // Reset horizontal counter
            // Vertical counter
            if (v_count == V_TOTAL - 1) begin
                v_count <= 0; // Reset vertical counter (frame complete)
            end else begin
                v_count <= v_count + 1; // Increment vertical counter
            end
        end else begin
            h_count <= h_count + 1; // Increment horizontal counter
        end
        // HSYNC generation (Active Low)
        if (h_count >= H_ACTIVE + H_FP && h_count < H_ACTIVE + H_FP + H_SYNC) begin
            r_hsync <= 0; // Active low
        end else begin
            r_hsync <= 1; // Inactive high
        end
        // VSYNC is low during the sync pulse period
        if (v_count >= V_ACTIVE + V_FP && v_count < V_ACTIVE + V_FP + V_SYNC) begin
            r_vsync <= 0; // Active low
        end else begin
            r_vsync <= 1; // Inactive high
        end
        // Determine if current pixel is within the active display area
        r_h_active = (h_count < H_ACTIVE);
        r_v_active = (v_count < V_ACTIVE);

        // Color generation logic 
        if (r_h_active && r_v_active && xorrings) begin            
            r_vga_red   <= 7; 
            r_vga_green <= 7; 
            r_vga_blue  <= 7; 
        end else begin
            // Blanking period (outside active area), output black
            r_vga_red   <= 0;
            r_vga_green <= 0;
            r_vga_blue  <= 0;
        end
    end
    // assign outputs
    assign hsync     = r_hsync;
    assign vsync     = r_vsync;
    assign vga_red   = r_vga_red;
    assign vga_green = r_vga_green;
    assign vga_blue  = r_vga_blue;
endmodule

