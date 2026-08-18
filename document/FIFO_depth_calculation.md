FIFO depth calculation determines the buffer size needed to prevent data loss (overflow) when passing data between two clock domains or processing rates.

---

## Core Concept

When data is written faster than it is read during a burst, the FIFO absorbs the difference.

$$\text{FIFO Depth} = \text{Data Written during Burst} - \text{Data Read during Burst}$$

---

## General Formula

$$\text{Depth} = B - \left( \frac{B}{f_w} \cdot f_r \cdot \frac{\text{Read Efficiency}}{\text{Write Efficiency}} \right)$$

Where:

* $B$ = Burst size (number of consecutive data items written)
* $f_w$ = Write clock frequency
* $f_r$ = Read clock frequency
* Time to write burst $T_{\text{burst}} = \frac{B}{f_w}$

---

## Step-by-Step Calculation Framework

1. **Find the total burst write duration ($T_{\text{burst}}$):**

$$T_{\text{burst}} = \frac{\text{Burst Size}}{\text{Write Frequency}} \times \text{Clocks per Write}$$


2. **Calculate how many items are read during $T_{\text{burst}}$:**

$$\text{Items Read} = \frac{T_{\text{burst}}}{\text{Time per Read}} = T_{\text{burst}} \times \left( \frac{f_r}{\text{Clocks per Read}} \right)$$


3. **Subtract reads from total burst size:**

$$\text{Min FIFO Depth} = \text{Burst Size} - \text{Items Read}$$



---

## Standard Example

### **Scenario parameters:**

* **Write Clock ($f_w$):** $100\text{ MHz}$ ($1\text{ data item / cycle}$)
* **Read Clock ($f_r$):** $50\text{ MHz}$ ($1\text{ data item / cycle}$)
* **Burst Size ($B$):** $80\text{ data items}$
* **No delay cycles between writes or reads during the burst.**

### **Calculation:**

1. **Time to write 80 items:**

$$T_{\text{burst}} = \frac{80}{100\text{ MHz}} = 800\text{ ns}$$


2. **Items read in $800\text{ ns}$:**

$$\text{Items Read} = 800\text{ ns} \times 50\text{ MHz} = 40\text{ items}$$


3. **Required FIFO Depth:**

$$\text{Depth} = 80 - 40 = 40$$



---

## Critical Edge Case: Back-to-Back Bursts

If write data arrives in periodic duty-cycle bursts (e.g., 80 items every 100 write cycles), the worst-case timing occurs when two bursts happen back-to-back: the tail of one window directly connects to the head of the next window.

* **Effective Burst Size ($B_{\text{worst}}$):** $2 \times B$
* Apply the same formula using $B_{\text{worst}}$ to calculate safe depth under worst-case jitter/alignment.



