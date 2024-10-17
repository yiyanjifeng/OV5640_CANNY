module vip_matrix_generate_5x5_8bit
(
    input             clk,  
    input             rst_n,

    input             pre_frame_vsync,
    input             pre_frame_href,
    input             pre_frame_clken,
    input      [7:0]  pre_img_y,
    
    output            matrix_frame_vsync,
    output            matrix_frame_href,
    output            matrix_frame_clken,
    output reg [7:0]  matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15,
    output reg [7:0]  matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25,
    output reg [7:0]  matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35,
    output reg [7:0]  matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45,
    output reg [7:0]  matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55
);

// Wire definition
wire [7:0] row_data[0:4]; // Array for row data
wire       read_frame_href;
wire       read_frame_clken;

// Reg definition
reg  [7:0] pre_img_y_d[0:4]; // Shift registers for storing pixel data
reg  [7:0] pre_frame_vsync_r;
reg  [7:0] pre_frame_href_r;
reg  [7:0] pre_frame_clken_r;

// Main code starts here
assign read_frame_href    = pre_frame_href_r[6];
assign read_frame_clken   = pre_frame_clken_r[6];
assign matrix_frame_vsync = pre_frame_vsync_r[7];
assign matrix_frame_href  = pre_frame_href_r[7];
assign matrix_frame_clken = pre_frame_clken_r[7];

// Delay input data
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pre_img_y_d[0] <= 0;
        pre_img_y_d[1] <= 0;
        pre_img_y_d[2] <= 0;
        pre_img_y_d[3] <= 0; 
    end else begin
        pre_img_y_d[0] <= pre_img_y;
        pre_img_y_d[1] <= pre_img_y_d[0];
        pre_img_y_d[2] <= pre_img_y_d[1];
        pre_img_y_d[3] <= pre_img_y_d[2];
        
    end
end

// RAM for storing column data
line_shift_ram_8bit_output5 u_line_shift_ram_8bit_output5
(
    .clock          (clk),
    .clken          (pre_frame_clken),
    .pre_frame_href (pre_frame_href),
    
    .shiftin        (pre_img_y),   
    .taps0x         (row_data[0]),   // Row 1
    .taps1x         (row_data[1]),   // Row 2
    .taps2x         (row_data[2]),   // Row 3
    .taps3x         (row_data[3])   // Row 4
    
);

// Delay sync signals
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pre_frame_vsync_r <= 0;
        pre_frame_href_r  <= 0;
        pre_frame_clken_r <= 0;
    end else begin
        pre_frame_vsync_r <= {pre_frame_vsync_r[6:0], pre_frame_vsync};
        pre_frame_href_r  <= {pre_frame_href_r[6:0], pre_frame_href};
        pre_frame_clken_r <= {pre_frame_clken_r[6:0], pre_frame_clken};
    end
end

// Output matrix generation
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15} <= 40'h0;
        {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25} <= 40'h0;
        {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35} <= 40'h0;
        {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45} <= 40'h0;
        {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55} <= 40'h0;
    end else if(read_frame_href) begin
        if(read_frame_clken) begin
            {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15} <= {matrix_p12, matrix_p13, matrix_p14, matrix_p15, row_data[0]};
            {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25} <= {matrix_p22, matrix_p23, matrix_p24, matrix_p25, row_data[1]};
            {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35} <= {matrix_p32, matrix_p33, matrix_p34, matrix_p35, row_data[2]};
            {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45} <= {matrix_p42, matrix_p43, matrix_p44, matrix_p45, row_data[3]};
            {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55} <= {matrix_p52, matrix_p53, matrix_p54, matrix_p55, row_data[4]};
        end else begin
            {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15} <= {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15};
            {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25} <= {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25};
            {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35} <= {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35};
            {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45} <= {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45};
            {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55} <= {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55};
        end
    end else begin
        {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15} <= 40'h0;
        {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25} <= 40'h0;
        {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35} <= 40'h0;
        {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45} <= 40'h0;
        {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55} <= 40'h0;
    end
end

endmodule