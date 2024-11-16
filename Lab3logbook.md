# Lab 3 - Finite State Machines (FSM)
## Task 0 - Setup GTest

### Introduction and download
A process of hardware design that we require in order to filter out and remove errors is called verification. This process involves model checking, logic checking and analysis to check its correctness (relative to specifications).

We will be using the **GTest** framework. This is a test framework - a software for writing and running unit tests.

#### An overview of TEST_F
Looking at the code:

```cpp
TEST_F(TestAdd, AddTest)
{
    // This should pass, 2 + 4 = 6
    EXPECT_EQ(add(2, 4), 6);
}
```

This code calls a function `add(n1, n2)`, which returns the result of n1 + n2. The second parameter is the value expected from this result. If these are incorrect, then the code will display a message displaying the test failure.

I wrote my own function to return the factorial of an input value n. Using the TEST_F function structure I tried invalid test condition:

```cpp
TEST_F(TestAdd, AddTest2)
{
    EXPECT_EQ(factorial(5), 4);
    // factorial(5) is actually 120
}
```

Running the file using `./doit.sh`, the result showed that my test fails:

```
main.cpp:37: Failure
Expected equality of these values:
  factorial(5)
    Which is: 120
  4
[  FAILED  ] TestAdd.AddTest2 (0 ms)
...
[  FAILED  ] 1 test, listed below:
[  FAILED  ] TestAdd.AddTest2
```

Very cool.

## Task 1 - 4-bit LFSR and Pseudo Random Binary Sequence
In the **lfsr.sv** file, I added a clocked `always_ff` loop. This implementation of my loop uses the primitive polynomial *1 + X<sup>3</sup> + X<sup>4</sup>*. The polynomial acts as a 'random' 4-bit counter where values will repeat every 2<sup>N-1</sup> values. The value will always reset to 1 - hence why an input is not included.

```
always_ff @ (posedge clk, posedge rst) begin
    if (rst && en)
        sreg <= 4'b1;
    else if (en)
        sreg <= {sreg[3:1], sreg[4] ^ sreg[3]};
    else
        sreg <= sreg
    assign data_out = sreg;
end
```
The use of `rst && en` is to incorporate both enable and reset signals with similar precedence. The signal can only be reset when enable is on.

Running `./verify.sh` provides me with a passing testcase. 

### Test yourself challenge
I added the always_ff loop into the **lfsr_&.sv** file, and made the change to the logic as by the primitive polynomial 1 + X<sup>3</sup> + X<sup>7</sup>.
``` 
sreg <= {sreg[6:1], sreg[7] ^ sreg[3]};
```

## Task 2 - Formula 1 Light Sequence

### Creating the component f1_fsm.sv
This is the file that specifies the FSM for the lights. The lights turn on in sequence - the values of *data_out* are formed logically by a left shift of the current output, and adding a value of 1. It must be noted that the states only change when *en* is set to 1 - this can be toggled using the function **vbdFlag()**.

#### Initialising states using enumeration
```
typedef enum {S0, S1, S2, S3, S4, S5, S6, S7, S8} light_state;
light_state current_state, next_state;
```
In the code above, a new type *light_state* is defined, with the characteristic of having 9 different states - where S0 is the state with no lights (*data->out* = 0) and the S8 is fully lit state. The line below initialises two new instances of the type *light_state*, as the current and next states have a relationship. This relationship is defined by the FSM and follows a fixed path.

#### Dealing with switchcases
The states can be dealt with using combinational logic, so the use of an *always_comb* block and a switch case allows the evaluation of the value of the next state. In this case, the next state is only one value, and does NOT depend on the input. 
```
always_comb begin
    case (current_state)
        S0      :     next_state = S1;
        S1      :     next_state = S2;
        S2      :     next_state = S3;
        S3      :     next_state = S4;
        S4      :     next_state = S5;
        S5      :     next_state = S6;
        S6      :     next_state = S7;
        S7      :     next_state = S8;
        S8      :     next_state = S0;
        default :     next_state = current_state;                 
    endcase
end
```
With the code:
* Make sure that both the case and the combinational logic blocks are closed with an `end` or `endcase` as seen.
* There is also a combinational logic block for the outputs.

### Connecting the FSM to Vbuddy
```
vbdBar(top->data_out & 0xFF);
```
The main objective of this task is to display the FSM on the LED lights on the Vbuddy. The code above is what displays the values on the LEDs, but is seen that the data is **masked** by 0xFF. This is done so that the bits that are 1s can be kept, and the other values are 0. This is why a bitwise AND operation is applied.

## Task 3 - Exploring the *clktick.sv* and the *delay.sv* modules
For my code: the N value is 25. This is the N required for my lights to flash at roughly 60bpm, running on a 14" Lenovo IdeaPad Pro5 (R7-8845HS).

### What does N do/affect?
#### N within the .sv file
```
always_ff @ (posedge clk)
    if (rst) begin
        tick <= 1'b0;
        count <= N;  
        end
    else if (en) begin
        if (count == 0) begin
            tick <= 1'b1;
            count <= N;
            end
        else begin
            tick <= 1'b0;
            count <= count - 1'b1;
            end
        end
```
Within the SystemVerilog module, N is introduced as an input interface signal to the program with a bit width defined by the parameter *WIDTH* (at the top of the module). In the code, it can be seen that clktick is synchronous - running at intervals of the clock signal.

The code above works by:
* setting the *count* to N (from the Vbuddy). This occurs when *rst* is 1
* otherwise, if the count is 0, then the chosen clock resets
* the value of N is the number of clock cycles between each tick
* the 'else' case is when *count* is not 0, so the count value decrements

#### N within the testbench
```
if (top->tick)
    {
    vbdBar(lights);
    lights = lights ^ 0xFF;
    }
```
This outputs the bar of lights whenever the tick is set to 1. *lights* is initialised as a `main()` variable, at the top of the program, with value 0. The `^` operator performs an XOR between these two values, so `0x00 ^ 0xFF` would be 0xFF.

### Test yourself challenge
This connects both **clktick** and **f1fsm**.
