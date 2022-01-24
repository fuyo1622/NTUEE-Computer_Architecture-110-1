`timescale 1ns/10ps
`define CLCYE_TIME 10.0
// You can modify NUM_DATA and MAX_DELAY
`define NUM_DATA 10
`define MAX_DELAY 3

module test_HW2();
    reg         clk, rst_n;
    reg  [31:0] A, B;
    wire [63:0] Z;
    reg         valid;
    reg  [1:0]  mode;
    wire        ready;
    wire [63:0] product;
    reg  [63:0] product_ans;
    wire [31:0] quotient, remainder;
    reg  [31:0] quotient_ans, remainder_ans;
    wire [63:0] and_temp;
    reg  [63:0] and_ans;
    wire [63:0] or_temp;
    reg  [63:0] or_ans;

    parameter num_data = `NUM_DATA;
    integer i, delay_num, err_mul, err_div, err_and, err_or;

    ALU U0( 
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .ready(ready),
        .mode(mode),
        .in_A(A),
        .in_B(B),
        .out(Z)
    );

    assign product = Z;
    assign {remainder, quotient} = Z;
    assign and_temp = Z;
    assign or_temp = Z;

    // Clock waveform definition
    always #(`CLCYE_TIME*0.5) clk = ~clk;

    // Write out waveform
    initial begin
        $fsdbDumpfile("HW2.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    // Stimuli and check
    initial begin
        clk = 1;
        rst_n = 1;
        valid = 0;
        mode = 0;
        A = 0;
        B = 0;
        product_ans = 0;
        quotient_ans = 0;
        remainder_ans = 0;
        i = 0;
        err_mul = 0;
        err_div = 0;
        err_and = 0;
        err_or = 0;

        #(`CLCYE_TIME*0.5);
        rst_n = 0;
        #(`CLCYE_TIME);
        rst_n = 1;

        // Multiplication
        $display("-------------------------------------------");
        $display("Test function of multiplication...");
        for (i=1; i<=`NUM_DATA; i=i+1) begin
            delay_num = $abs($random()%`MAX_DELAY)+1;
            #(`CLCYE_TIME*delay_num)
            valid = 1;
            A = $random%32'hFFFF_FFFF; // change your pattern here
            B = $random%32'hFFFF_FFFF; // change your pattern here
            product_ans = A*B;
            
            #(`CLCYE_TIME)
            valid = 0;
            A = 0;
            B = 0;

            #(`CLCYE_TIME*32)
            if (ready) begin
                if (product !== product_ans) begin
                    $display("Error at pattern number %3d", i);
                    $display("\texpected answer: %8h", product_ans);
                    $display("\t    your answer: %8h", product    );
                    err_mul = err_mul + 1;
                end
            end
            else begin
                $display("Does not detect ready at pattern number %3d", i);
                err_mul = err_mul + 1;
            end
        end
        if (err_mul == 0)
            $display("Multiplication task correct");
        else
            $display("Multiplication task wrong");

        // Division
        $display("Test function of division...");
        for (i=1; i<=`NUM_DATA; i=i+1) begin
            delay_num = $abs($random()%`MAX_DELAY)+1;
            #(`CLCYE_TIME*delay_num)
            valid = 1;
            mode = 1;
            A = $random()%32'hFFFF_FFFF  ; // change your pattern here
            B = $random()%32'h7FFF_FFFF+1; // change your pattern here
            quotient_ans  = A/B;
            remainder_ans = A%B;
            
            #(`CLCYE_TIME);
            valid = 0;
            mode = 0;
            A = 0;
            B = 0;

            #(`CLCYE_TIME*32);
            if (ready) begin
                if ((quotient !== quotient_ans) || (remainder !== remainder_ans)) begin
                    $display("Error at pattern number %3d", i);
                    $display("\texpected answer: Q = %8h, R = %8h", quotient_ans, remainder_ans);
                    $display("\t    your answer: Q = %8h, R = %8h", quotient    , remainder    );
                    err_div = err_div + 1;
                end
            end
            else begin
                $display("Does not detect ready at pattern number %3d", i);
                err_div = err_div + 1;
            end
        end
        if (err_div == 0)
            $display("Division task correct");
        else
            $display("Division task wrong");

        $display("Test function of AND...");
        for (i=1; i<=`NUM_DATA; i=i+1) begin
            delay_num = $abs($random()%`MAX_DELAY)+1;
            #(`CLCYE_TIME*delay_num)
            valid = 1;
            mode = 2;
            A = $random%32'hFFFF_FFFF; // change your pattern here
            B = $random%32'hFFFF_FFFF; // change your pattern here
            and_ans[63:32] = 32'd0;
            and_ans[31:0] = A & B;
            
            #(`CLCYE_TIME)
            valid = 0;
            mode = 0;
            A = 0;
            B = 0;

            #(`CLCYE_TIME)
            if (ready) begin
                if (and_temp !== and_ans) begin
                    $display("Error at pattern number %3d", i);
                    $display("\texpected answer: %8h", and_ans);
                    $display("\t    your answer: %8h", and_temp);
                    err_and = err_and + 1;
                end
            end
            else begin
                $display("Does not detect ready at pattern number %3d", i);
                err_and = err_and + 1;
            end
        end

        if (err_and == 0)
            $display("AND task correct");
        else
            $display("AND task wrong");

        $display("Test function of OR...");
        for (i=1; i<=`NUM_DATA; i=i+1) begin
            delay_num = $abs($random()%`MAX_DELAY)+1;
            #(`CLCYE_TIME*delay_num)
            valid = 1;
            mode = 3;
            A = $random%32'hFFFF_FFFF; // change your pattern here
            B = $random%32'hFFFF_FFFF; // change your pattern here
            or_ans[63:32] = 32'd0;
            or_ans[31:0] = A | B;
            
            #(`CLCYE_TIME)
            valid = 0;
            mode = 0;
            A = 0;
            B = 0;

            #(`CLCYE_TIME)
            if (ready) begin
                if (or_temp !== or_ans) begin
                    $display("Error at pattern number %3d", i);
                    $display("\texpected answer: %8h", or_ans);
                    $display("\t    your answer: %8h", or_temp);
                    err_or = err_or + 1;
                end
            end
            else begin
                $display("Does not detect ready at pattern number %3d", i);
                err_or = err_or + 1;
            end
        end

        if (err_or == 0)
            $display("OR task correct");
        else
            $display("OR task wrong");

        if ((err_mul == 0) && (err_div == 0) && (err_and == 0) && (err_or == 0) ) begin
            $display("-------------------------------------------");
            $display("-   Success!! You passed the simulation   -");
            $display("-------------------------------------------\n");
        end
        else begin
            $display("-------------------------------------------");
            $display("- Wrong!! Please check your design again  -");
            $display("-------------------------------------------\n");
        end
        $finish;
    end

endmodule