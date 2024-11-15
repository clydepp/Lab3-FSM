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


### Connecting the FSM to Vbuddy


## Task 3 - Exploring the *clktick.sv* and the *delay.sv* modules
