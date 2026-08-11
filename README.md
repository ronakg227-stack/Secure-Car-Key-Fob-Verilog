Markdown# 🚗 Advanced Smart Car Key Fob Controller (Verilog/Vivado)

**Institution:** Delhi Technological University (DTU)  
**Department:** Electronics and Communication Engineering (ECE)  
**Batch:** 24/EC  
**Author:** Ronak Gupta  

---

## 🎯 1. Experiment Aim & Software Used
* **Aim:** To design, simulate, and verify a fundamental automotive car key fob controller, and subsequently upgrade it into an advanced, state-machine-driven secure system featuring anti-glitch protection, trunk automation, and a 3-strike anti-theft alarm.
* **Software Used:** AMD Vivado Design Suite 2026.1 (For RTL Design, Behavioral Simulation, and Hardware Synthesis).

---

## 🛠️ 2. Phase 1: Basic Fob Controller (Initial Design)

### 2.1 Theoretical Background & Logic
The initial phase involves designing a purely combinatorial comparator circuit. The fundamental logic dictates that upon receiving a high `rx_trigger` signal, the system matches a 16-bit input `rx_key_code` against a hardcoded internal parameter (`16'hA5A5`). A successful match decodes the `rx_command` to assert either a lock (`2'b10`) or unlock (`2'b01`) signal via basic output registers.

### 2.2 Basic RTL Code (`car_key_fob_controller.v`)
```verilog
`timescale 1ns / 1ps
module car_key_fob_controller (
    input wire clk, input wire reset, input wire rx_trigger,         
    input wire [15:0] rx_key_code, input wire [1:0] rx_command,   
    output reg unlock_doors, output reg lock_doors
);
    localparam [15:0] VALID_CODE = 16'hA5A5;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            unlock_doors <= 1'b0; lock_doors <= 1'b0;
        end else begin
            unlock_doors <= 1'b0; lock_doors <= 1'b0;
            if (rx_trigger) begin
                if (rx_key_code == VALID_CODE) begin
                    if (rx_command == 2'b01) unlock_doors <= 1'b1;
                    else if (rx_command == 2'b10) lock_doors <= 1'b1;
                end
            end
        end
    end
endmodule
2.3 Simulation & Hardware Analysis (Basic Design)Behavioral Simulation (Lock/Unlock successful):[<img width="1917" height="1079" alt="Screenshot 2026-08-11 181013" src="https://github.com/user-attachments/assets/3eef5f28-0c67-4412-b094-2e02a8ada122" />
]RTL Schematic (Combinatorial logic):[<img width="1918" height="1073" alt="Screenshot 2026-08-11 181219" src="https://github.com/user-attachments/assets/3bbfd4b4-2813-4f2e-9520-73702fa476ae" />
]Hardware Utilization & Power:Slice LUTs: 5 | Registers: 2Total On-Chip Power: 0.224 W[<img width="1906" height="1030" alt="Screenshot 2026-08-11 181538" src="https://github.com/user-attachments/assets/b3e11466-1bc3-4b4e-8b10-8485f8b03d63" />
 / <img width="1919" height="1079" alt="Screenshot 2026-08-11 181818" src="https://github.com/user-attachments/assets/b3aa5a18-3fdc-4661-9011-b10e997cca88" />
]🤖 3. Phase 2: R&D and AI Prompting for Advanced FeaturesTo transition this basic logic into an industry-ready automotive product, advanced threat vectors (such as brute-force RF attacks) and mechanical flaws (accidental pocket presses) were analyzed. Generative AI was leveraged as an architectural co-pilot to construct a secure Finite State Machine (FSM).Architecture Upgrade Prompt:"I have successfully built a basic Verilog car key fob. Now I want to upgrade it. Suggest changes and Verilog logic to include: 1) A MacBook-style accidental pocket press protection (button must be held for some time). 2) A trunk release automation. 3) Security reasons/threats and how to tackle them like a 3-strike brute force lockout with an alarm."AI Suggested Architecture: Shift to a Synchronous Sequential Circuit incorporating:Hold-Time Accumulator: A counter that validates a press only if held for consecutive clock cycles (Anti-Glitch).Trunk Command Decoder: Expanding the output routing to accept 2'b11.Security Lockout Mechanism: A register tracking sequential failed attempts, tripping an active-high alarm_active signal upon reaching 3 consecutive failures.🚀 4. Phase 3: Advanced Secure Fob Controller Implementation4.1 Advanced RTL Code (car_key_fob_advanced.v)Verilog`timescale 1ns / 1ps
module car_key_fob_advancedversion (
    input wire clk, input wire reset, input wire rx_trigger,         
    input wire [15:0] rx_key_code, input wire [1:0] rx_command,   
    output reg unlock_doors, output reg lock_doors,
    output reg open_trunk, output reg alarm_active        
);
    localparam [15:0] VALID_CODE = 16'hA5A5;
    localparam MAX_ATTEMPTS = 2'd3;
    localparam HOLD_TIME = 3'd4;   

    reg [1:0] failed_attempts;
    reg locked_out;
    reg [2:0] trigger_counter;     

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            unlock_doors <= 1'b0; lock_doors <= 1'b0; open_trunk <= 1'b0;
            alarm_active <= 1'b0; failed_attempts <= 2'd0;
            locked_out <= 1'b0; trigger_counter <= 3'd0;
        end else begin
            unlock_doors <= 1'b0; lock_doors <= 1'b0; open_trunk <= 1'b0;

            if (rx_trigger && !locked_out) begin
                if (trigger_counter < HOLD_TIME) begin
                    trigger_counter <= trigger_counter + 1'b1; 
                end else if (trigger_counter == HOLD_TIME) begin
                    if (rx_key_code == VALID_CODE) begin
                        failed_attempts <= 2'd0; 
                        case (rx_command)
                            2'b01: unlock_doors <= 1'b1;
                            2'b10: lock_doors <= 1'b1;
                            2'b11: open_trunk <= 1'b1; 
                        endcase
                    end else begin
                        failed_attempts <= failed_attempts + 1'b1;
                        if (failed_attempts == MAX_ATTEMPTS - 1) begin
                            locked_out <= 1'b1;
                            alarm_active <= 1'b1; 
                        end
                    end
                    trigger_counter <= trigger_counter + 1'b1; 
                end
            end else if (!rx_trigger) begin
                trigger_counter <= 3'd0; 
            end
        end
    end
endmodule
4.2 Simulation & Hardware Analysis (Advanced Design)Advanced Behavioral Simulation (Anti-glitch & Alarm success):[<img width="1919" height="1079" alt="Screenshot 2026-08-11 185731" src="https://github.com/user-attachments/assets/ed221935-8cfc-4a2d-ab1f-e3cf635eb98b" />
]Advanced RTL Schematic (Expanded FSM routing):[<img width="1916" height="1004" alt="Screenshot 2026-08-11 185949" src="https://github.com/user-attachments/assets/e5890897-4ba0-4d76-8b52-05554ad2e00c" />
]Advanced Hardware Utilization & Power:Slice LUTs: 11 | Registers: 9Total On-Chip Power: 0.309 W[<img width="1916" height="1073" alt="Screenshot 2026-08-11 190530" src="https://github.com/user-attachments/assets/eb55cdb6-2bdb-4c14-8f57-3a8a407978f4" />
]
⚖️ 5. Comparison & Engineering Trade-off Analysis

Deploying functional safety and security features in embedded hardware necessitates a fundamental trade-off between architectural robustness, spatial logic cost, and power dissipation.

<br>

| Design Metric | Basic Fob Controller | Advanced Secure Fob Controller | Engineering Trade-off / Impact Analysis |
| :--- | :--- | :--- | :--- |
| **Primary Features** | Standard Lock / Unlock | Anti-Glitch Filter + Trunk Release + 3-Strike Alarm | Functional safety and security limits drastically enhanced against physical/RF bypasses. |
| **Logic (Slice LUTs)** | 5 LUTs | 11 LUTs | **Increased:** Accommodating additional combinational routing for multiplexers and logic comparison. |
| **Memory (Registers)**| 2 Registers | 9 Registers | **Increased (4.5x):** High utilization of D-Flip-Flops to preserve operational states (Hold timer and Failed Attempts). |
| **Total On-Chip Power** | 0.224 W | 0.309 W | **Increased:** Approximately 38% rise in dynamic power dissipation due to elevated switching activity of the sequential logic. |

<br>

🏁 6. Conclusion
This project successfully mapped the complete hardware development life cycle of an automotive subsystem. Beginning with a baseline combinatorial design, the system was scaled into an advanced FSM capable of handling real-world vulnerabilities like accidental triggers and brute-force key injection. The implementation validates a core VLSI concept: advancing system security directly correlates with a proportional increase in hardware footprint (Registers/LUTs) and dynamic power consumption.
