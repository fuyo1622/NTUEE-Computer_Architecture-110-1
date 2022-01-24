module ALU(
    clk,
    rst_n,
    valid,
    ready,
    mode,
    in_A,
    in_B,
    out
);

    // Definition of ports
    input         clk, rst_n;
    input         valid;
    input  [1:0]  mode; // mode: 0: mulu, 1: divu, 2: and, 3: or
    output        ready;
    input  [31:0] in_A, in_B;
    output [63:0] out;

    // Definition of states
    parameter IDLE = 3'd0;
    parameter MUL  = 3'd1;
    parameter DIV  = 3'd2;
    parameter AND = 3'd3;
    parameter OR = 3'd4;
    parameter OUT  = 3'd5;

    // Todo: Wire and reg if needed
    reg  [ 2:0] state, state_nxt;
    reg  [ 4:0] counter, counter_nxt;
    reg  [63:0] shreg, shreg_nxt;
    reg  [31:0] alu_in, alu_in_nxt;
    reg  [32:0] alu_out;
    reg  [63:0] out;
    reg  [0:0] ready;
    // Todo: Instatiate any primitives if needed

    // Todo 5: Wire assignments
    always @(*) begin
        if (state == 3'd5) begin
            case(mode)
                3: out = shreg[31:0];
                2: out = shreg[31:0];
                1: out = shreg[63:0];
                0: out = shreg[63:0];
            endcase
            ready = 1;
        end
        else begin
            out = 0;
            ready = 0;
        end
    end     
    // Combinational always block
    // Todo 1: Next-state logic of state machine
    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) begin
                    case(mode)
                    0 : begin
                        state_nxt = MUL;
                    end
                    1 : begin
                        state_nxt = DIV;
                    end
                    2 : begin 
                        state_nxt = AND;
                    end
                    3 : begin
                        state_nxt = OR;
                    end
                    endcase
                end
                else begin
                    state_nxt = IDLE;
                end
            end
            MUL : begin 
                if (counter != 5'd31) begin
                    state_nxt = MUL;
                end
                else begin
                    state_nxt = OUT;
                end
            end
            DIV : begin
                if (counter != 5'd31) begin
                    state_nxt = DIV;
                end
                else begin
                    state_nxt = OUT;
                end
            end
            AND : begin
                state_nxt = OUT;
            end
            OR  : begin
                state_nxt = OUT;   
            end
            OUT : begin
                state_nxt = IDLE;
            end
            default : begin
                state_nxt = IDLE;
            end
        endcase
    end
    // Todo 2: Counter
    always @(*) begin
        case(state)
            MUL : begin
                counter_nxt = counter + 1;
            end
            DIV : begin
                counter_nxt = counter + 1;               
            end
            default: begin
                counter_nxt = 0;
            end

            
        endcase
    end    
    // ALU input
    always @(*) begin
        case(state)
            OUT : begin
                alu_in_nxt = 0;
            end
            default: begin           
                if (valid) begin
                    alu_in_nxt = in_B;
                end
                else begin
                    alu_in_nxt = alu_in;
                end
            end
        endcase
    end

    // Todo 3: ALU output
    always @(*) begin
        case(state)
            AND: alu_out = shreg[31:0] & alu_in;
            OR : alu_out = shreg[31:0] | alu_in;
            MUL: begin
                if (shreg[0] == 1'b1) alu_out = alu_in;
                else alu_out = 0;
            end
            DIV: begin
                alu_out = shreg[62:31] - alu_in;
            end
            default: alu_out = 0;
        endcase
    end    
    // Todo 4: Shift register
    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) begin
                    shreg_nxt = {32'b0,in_A};
                end
                else begin
                    shreg_nxt = 0;
                end
            end
            AND: begin
                shreg_nxt = {shreg[63:32],alu_out[31:0]};
            end
            OR: begin
                shreg_nxt = {shreg[63:32],alu_out[31:0]};
            end
            MUL: begin
                shreg_nxt = {shreg[63:32]+alu_out[31:0],shreg[31:0]} >> 1;
                if (shreg_nxt[62:31] < shreg[63:32]) shreg_nxt[63] = 1;
                else shreg_nxt[63] = 0;
            end
            DIV: begin
                if (alu_out[32] == 1) shreg_nxt = shreg << 1;
                else begin
                    shreg_nxt = {1'b0,alu_out[31:0],shreg[30:0]}<<1;                                      
                    shreg_nxt[0] = 1;
                end
            end
            default: begin
                shreg_nxt = 0;
            end

        endcase
    end    
    // Todo: Sequential always block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= state_nxt;
            counter <= counter_nxt;
            shreg <= shreg_nxt;
            alu_in <= alu_in_nxt;
        end
    end

endmodule