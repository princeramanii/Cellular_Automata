// 1D Cellular Automaton Pattern Generator for Helium CPLD Board
// Automatically advances generations using onboard 1Hz clock

module cellular_automaton(
    input wire clk,          // Onboard 1Hz clock (PIN 43)
    input wire [7:0] sw,     // 8-bit switch input (PIN 4,5,6,8,9,11,12,14)
    output reg [7:0] led     // 8-bit LED output (PIN 24,25,26,27,28,29,31,33)
);
    // Registers for storing states
    reg [7:0] current_state;
    reg [7:0] rule;
    reg initialized;         // Flag to track if initial pattern is loaded
    
    // Internal signals
    wire [7:0] next_state;
    wire any_switch_on;
    
    // Check if any switch is turned on
    assign any_switch_on = |sw;
    
    // Calculate next state for each cell based on rule
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin: next_state_logic
            // Get neighborhood pattern (3 bits: left neighbor, current cell, right neighbor)
            wire [2:0] neighborhood;
            assign neighborhood[2] = current_state[(i == 0) ? 7 : i-1];     // Left neighbor (wrap around)
            assign neighborhood[1] = current_state[i];                       // Current cell
            assign neighborhood[0] = current_state[(i == 7) ? 0 : i+1];      // Right neighbor (wrap around)
            
            // Apply rule based on neighborhood pattern
            assign next_state[i] = rule[neighborhood];
        end
    endgenerate
    
    // State control logic
    always @(posedge clk) begin
        if (!initialized && any_switch_on) begin
            // First time a switch is on, load the initial state
            current_state <= sw;
            rule <= 8'b00011110;  // Rule 30
            initialized <= 1;     // Mark as initialized
        end 
        else if (initialized) begin
            // Auto-advance to next generation on each clock cycle
            current_state <= next_state;
        end
    end
    
    // Output current state to LEDs
    always @(*) begin
        led = current_state;
    end
    
    // Initialize state
    initial begin
        current_state = 8'b00000000;
        rule = 8'b00011110;       // Rule 30
        initialized = 0;
    end
endmodule
