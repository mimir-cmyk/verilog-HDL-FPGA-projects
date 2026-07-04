module traffic_light_controller(
    input clk,
    input reset,
    input Sa,
    input Sb,
    input ped_req,
    input night_mode,

    output reg Ga,
    output reg Ya,
    output reg Ra,
    output reg Gb,
    output reg Yb,
    output reg Rb,
    output reg Pwalk,
    output reg Pstop
);
// timing parameters
parameter TICKS_PER_10S = 1;

localparam A_GREEN_TIME= 6 * TICKS_PER_10S; //60s
localparam B_GREEN_TIME = 4 * TICKS_PER_10S; //40s
localparam YELLOW_TIME = 1 * TICKS_PER_10S; //10s
localparam PED_TIME  = 2 * TICKS_PER_10S; //20s
localparam B_EXT_TIME= 1 * TICKS_PER_10S; //10s
localparam BLINK_TIME= 1 * TICKS_PER_10S; //10s
//states

localparam A_GREEN = 3'd0;
localparam A_YELLOW= 3'd1;
localparam B_GREEN = 3'd2;
localparam B_YELLOW = 3'd3;
localparam ALL_RED_BEFORE_PED  = 3'd4;
localparam PED_WALK = 3'd5;
localparam NIGHT_BLINK_ON = 3'd6;
localparam NIGHT_BLINK_OFF= 3'd7;

reg [2:0] current_state;
reg [2:0] next_state;
//timer
reg [7:0] timer;
//stored pedestrian request

reg ped_pending;
//state register
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        current_state <= A_GREEN;
        timer <= 0;
        ped_pending <= 0;
    end
    else
    begin
    if(ped_req)
    ped_pending <= 1'b1;

   if(night_mode)
   begin
     if(current_state != NIGHT_BLINK_ON && current_state != NIGHT_BLINK_OFF)
 begin
  current_state <= NIGHT_BLINK_ON;
    timer <= 0;
    end
  else begin
 current_state <= next_state;
if(timer >= BLINK_TIME-1)
    timer <= 0;
  else
 timer <= timer + 1;
  end
   end
    else
begin
if(current_state == NIGHT_BLINK_ON ||  current_state == NIGHT_BLINK_OFF)
 begin
current_state <= A_GREEN;
 timer <= 0;
  ped_pending <= 0;
 end
 else begin
current_state <= next_state;
if(next_state != current_state)
  timer <= 0;
else
 timer <= timer + 1;
if(current_state == PED_WALK && timer >= PED_TIME-1)
 ped_pending <= 0;
 end
  end
   end
end

//next state logic

always @(*)
begin

    next_state = current_state;
    case(current_state)
   
    A_GREEN:
    begin
 if(timer >= A_GREEN_TIME-1)
   begin
  if(ped_pending)
   next_state = A_YELLOW;
   else if(Sb)
     next_state = A_YELLOW;
        end
    end

    A_YELLOW:
    begin
        if(timer >= YELLOW_TIME-1)
        begin
     if(ped_pending)
       next_state = ALL_RED_BEFORE_PED;
        else
       next_state = B_GREEN;
        end
    end

    B_GREEN:
    begin

        if(timer >= B_GREEN_TIME-1)
        begin
         if(ped_pending)
           next_state = B_YELLOW;

      else if((Sb == 1'b1) && (Sa == 1'b0))
        begin
     if(timer >= (B_GREEN_TIME+B_EXT_TIME)-1)
      next_state = B_YELLOW;
       else
       next_state = B_GREEN;
         end
       else
      next_state = B_YELLOW;
        end
    end

    B_YELLOW:
    begin
        if(timer >= YELLOW_TIME-1)
        begin
    if(ped_pending)
      next_state = ALL_RED_BEFORE_PED;
      else
     next_state = A_GREEN;
        end
    end

    ALL_RED_BEFORE_PED:
    begin
        if(timer >= YELLOW_TIME-1)
            next_state = PED_WALK;
    end
    PED_WALK:
    begin
        if(timer >= PED_TIME-1)
            next_state = A_GREEN;
    end
    NIGHT_BLINK_ON:
    begin
        if(timer >= BLINK_TIME-1)
            next_state = NIGHT_BLINK_OFF;
    end
    NIGHT_BLINK_OFF:
    begin
        if(timer >= BLINK_TIME-1)
            next_state = NIGHT_BLINK_ON;
    end

    default:
        next_state = A_GREEN;

    endcase
    end
	// output logic
	always @(*)
	begin
    Ga = 0;
    Ya= 0;
    Ra= 0;
    Gb =0;
    Yb=0;
    Rb= 0;
    Pwalk= 0;
    Pstop = 1;

    case(current_state)

    A_GREEN:
    begin
        Ga = 1;
        Rb=1;
    end

    A_YELLOW:
    begin
        Ya= 1;
        Rb = 1;
    end

    B_GREEN:
    begin
        Ra= 1;
        Gb = 1;
    end

    B_YELLOW:
    begin
        Ra = 1;
        Yb=1;
    end

    ALL_RED_BEFORE_PED:
    begin
        Ra = 1;
        Rb = 1;
    end

    PED_WALK:
    begin
        Ra = 1;
        Rb = 1;
        Pwalk = 1;
        Pstop = 0;
    end

    NIGHT_BLINK_ON:
    begin
        Ya = 1;
        Yb = 1;
        Pstop = 1;
    end

    NIGHT_BLINK_OFF:
    begin
        Pstop = 1;
    end

    endcase
	end

	endmodule
