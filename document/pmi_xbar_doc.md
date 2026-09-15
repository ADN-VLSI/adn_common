# PMI-to-PMI Crossbar Communication System — Project Documentation

---

## Table of Contents

1. [Theory](#1-theory)
2. [Q&A — Relevant Questions & Solutions](#2-qa--relevant-questions--solutions)
3. [Block Diagram](#3-block-diagram)
4. [Architectural Decisions](#4-architectural-decisions)
5. [Verification](#5-verification)
6. [Project Outcome](#6-project-outcome)
7. [Simulation Commands](#7-simulation-commands)
8. [Contribution Tables](#8-contribution-tables)

---

## 1. Theory

### 1.1 Overview

This project implements a **PMI-to-PMI Crossbar Communication System**, a fabric that connects **M master PMI (Protocol Memory Interface) signals** to **N slave PMI signals**, allowing any master to transact with any slave through a shared, arbitrated interconnect.

The system is split into two independent but coordinated data paths:

- **Forward Path (Request Path):** Master → Address Decoder → Request Crossbar → Round Robin Arbiter → Slave
- **Backward Path (Response Path):** Slave → Response Crossbar → Address Decoder side (In-Order Resp / Slave ID FIFO) → Master

Ordering and routing correctness are maintained end-to-end using two families of tracking FIFOs:

- **Slave ID FIFO** (one per master) — records, in issue order, which slave each outstanding request was routed to.
- **Master ID FIFO** (one per slave) — records, in arbitration-granted order, which master is currently owed a response from that slave.

### 1.2 Forward Path (Request Path) — Detailed Flow

1. **Master Interface (M0 … M(N-1))**
   Each master drives a `PMI_REQ_T` (request) signal and receives a `PMI_RESP_T` (response) signal. Every master is wired into its own **Address Decoder** block.

2. **Address Decoder (per master, M instances)**
   - The Address Decoder is a **wrapper** around the core decode logic. It passes **all PMI request fields through untouched**, *except* the `maddr` (master address) field.
   - Only the `maddr` field is routed through the actual **decode logic**, which inspects the address and determines the target `slave_id [log2(M)-1:0]`.
   - The decoded `slave_id` is:
     - Appended back onto the outgoing `PMI_REQ_T` packet (so the crossbar knows where to route it), and
     - Simultaneously pushed into the **Slave ID FIFO** associated with that master.
   - This means the Address Decoder does two things per request: (a) forwards the full, tagged request downstream, and (b) records the routing decision locally for later use by the response path.

3. **Slave ID FIFO (per master, M instances)**
   - A FIFO that stores the sequence of `slave_id`s in the exact order the master issued requests.
   - This preserves **request ordering per master**, which is essential since responses may return out of order relative to issue order (multiple slaves, multiple masters, arbitration delays, etc.).
   - Works together with the **In-Order Resp** block (see §1.3) during the response phase.

4. **Request Crossbar**
   - Receives the tagged `PMI_REQ_T` + `slave_id` from all M address decoders.
   - Performs **routing only** — it does not interpret or modify the payload. Based on `slave_id`, it forwards the entire request packet to the correct **Round Robin Arbiter** (one arbiter exists per slave, N total).
   - Conceptually, the crossbar is a full M×N routing switch, but it operates purely as a mux/demux layer; all arbitration logic lives downstream in the arbiters.

5. **Round Robin Arbiter (per slave, N instances)**
   - Since multiple masters can target the same slave simultaneously, each slave has its own arbiter to resolve contention.
   - The arbiter selects one winning master request per grant cycle using round-robin priority (ensuring fairness/no starvation across masters).
   - The winning request's `master_id [log2(N)-1:0]` is pushed into the **Master ID FIFO** directly beneath that arbiter.
   - The granted `PMI_REQ_T` is then forwarded to the corresponding slave (S0 … S(M-1)).

6. **Master ID FIFO (per slave, N instances)**
   - Stores `master_id`s in the order requests were granted access to that slave.
   - This preserves **grant ordering per slave**, so that when the slave eventually responds, the system knows exactly which master is owed the next response.
   - Popped (`mack` / pop signal) when the corresponding response is sent back.

### 1.3 Backward Path (Response Path) — Detailed Flow

1. **Slave Response**
   - A slave (S0 … S(M-1)) issues a `PMI_RESP_T` response.
   - Before leaving the slave-side interface, the response is **packed together with**:
     - The `master_id` popped from that slave's **Master ID FIFO** (identifies which master should receive it), and
     - The slave's own `slave_id` (needed later for matching on the master side).

2. **Response Crossbar**
   - Receives the packed `PMI_RESP_T` + `master_id` + `slave_id` from all N slave-side arbiter blocks.
   - Routes strictly by `master_id` — all other response fields pass through unmodified.
   - Delivers the packet toward the correct master-side Address Decoder / In-Order Resp block.

3. **Master ID Pop**
   - Once routing through the Response Crossbar is complete, the `master_id` field has done its job and is **stripped off** the package.
   - What remains is the raw `PMI_RESP_T` payload plus the `slave_id` tag.

4. **In-Order Resp Block (per master, M instances)**
   - The incoming `slave_id` (carried with the response) is compared — via a **comparator module** — against the head entry of that master's **Slave ID FIFO**.
   - On a match:
     - The Slave ID FIFO **pops** that entry (confirming the response corresponds to the oldest outstanding request), and
     - The response payload (`PMI_RESP_T`) is released to the master.
   - This guarantees **in-order response delivery per master**, even though the underlying slaves/arbiters may service requests and generate responses out of order relative to one another.

### 1.4 Summary of Key Modules

| Module | Instances | Purpose |
|---|---|---|
| Address Decoder (wrapper + decode core) | M | Decodes `maddr` → `slave_id`; passes all other request fields through |
| Slave ID FIFO | M | Tracks per-master request order (which slave each request went to) |
| In-Order Resp | M | Compares/matches returning `slave_id` against Slave ID FIFO; releases response in order |
| Request Crossbar | 1 | Routes requests from M masters to N slaves based on `slave_id` |
| Round Robin Arbiter | N | Arbitrates among competing masters per slave; fair grant selection |
| Master ID FIFO | N | Tracks per-slave grant order (which master is owed the next response) |
| Response Crossbar | 1 | Routes responses from N slaves back to M masters based on `master_id` |

---

## 2. Q&A — Relevant Questions & Solutions

> *Space reserved for frequently raised questions during design/review discussions and their agreed-upon solutions.*

| # | Question | Solution / Resolution |
|---|---|---|
| 1 | *(e.g., How is response ordering guaranteed if slaves respond out of order?)* | *(fill in)* |
| 2 | *(e.g., What happens if the Slave ID FIFO or Master ID FIFO becomes full?)* | *(fill in)* |
| 3 | *(e.g., How does the comparator resolve simultaneous matches?)* | *(fill in)* |
| 4 | | |
| 5 | | |

---

## 3. Block Diagram

The top-level architecture (`PMI Crossbar Top`) is shown below, covering both the Request Crossbar and Response Crossbar paths, the per-master Address Decoder / Slave ID FIFO / In-Order Resp blocks, and the per-slave Round Robin Arbiter / Master ID FIFO blocks.

> **[INSERT BLOCK DIAGRAM IMAGE HERE — e.g. `![PMI Crossbar Top Block Diagram](./images/pmi_crossbar_block_diagram.svg)`]**

**Signal legend (as used in the diagram):**

- `PMI_REQ_T` — Full request packet (master → slave direction)
- `PMI_RESP_T` — Full response packet (slave → master direction)
- `slave_id [log2(M)-1:0]` — Decoded destination slave identifier, carried alongside requests
- `master_id [log2(N)-1:0]` — Granted master identifier, carried alongside responses
- `mack (pop)` — Pop/acknowledge strobe for the Master ID FIFO

---

## 4. Architectural Decisions

Two candidate micro-architectures were proposed before converging on the final (approved) design.

### 4.1 Proposal 1

> *(Describe the first proposed architecture, its routing scheme, pros/cons, and why it was or wasn't chosen.)*

- **Approach:**
- **Pros:**
- **Cons:**
- **Reason not selected / selected:**

### 4.2 Proposal 2

> *(Describe the second proposed architecture, its routing scheme, pros/cons, and why it was or wasn't chosen.)*

- **Approach:**
- **Pros:**
- **Cons:**
- **Reason not selected / selected:**

### 4.3 Approved Proposal

> *(Describe the final, approved architecture — this should map to the design detailed in §1 and §3 above.)*

- **Final approach:** Dual-crossbar design (separate Request Crossbar and Response Crossbar) with per-master Slave ID FIFOs and per-slave Master ID FIFOs plus Round Robin Arbitration, coordinated via comparator-based in-order response matching.
- **Key justification:**
- **Trade-offs accepted:**

---

## 5. Verification

### 5.1 UVM Testbench — Debug Flow

The verification environment is built around a UVM testbench targeting the PMI Crossbar Top. Debug activity flows from **testbench execution** into two tracked outcomes: **issues found** and **solutions applied**.

> **[INSERT UVM TESTBENCH ARCHITECTURE / DEBUG FLOW DIAGRAM HERE]**

```
Testbench (from: <fill in — e.g. UVM env, agents, scoreboard, sequences>)
        |
        v
   ---------------
   |             |
 Issues       Solutions
```

### 5.2 Debug Table

| # | Issue Found | Root Cause | Solution Applied | Status |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

---

## 6. Project Outcome

> *(Summarize final results: functional coverage achieved, bugs closed, performance/throughput observations, arbitration fairness results, any known limitations, and next steps.)*

- **Functional status:**
- **Coverage summary:**
- **Known limitations:**
- **Future work:**

---

## 7. Simulation Commands

> *(Fill in the exact compile/elaborate/simulate commands used for this project, e.g. VCS/Questa/Xcelium invocations, UVM verbosity flags, waveform dump options, regression scripts, etc.)*

```bash
# Compile
# <fill in compile command>

# Elaborate
# <fill in elaborate command>

# Simulate
# <fill in simulate command, e.g. with +UVM_TESTNAME=... +UVM_VERBOSITY=UVM_MEDIUM>

# Waveform / coverage
# <fill in>
```

---

## 8. Contribution Tables

### 8.1 Individual Contribution (Final Implementation)

| Member | Module(s) Owned | Contribution Summary |
|---|---|---|
| Member 1 | | |
| Member 2 | | |
| Member 3 | | |
| Member 4 | | |

### 8.2 Individual Idea Origins (Pre-Merge Proposals)

*Before converging on the final architecture, each member independently proposed an approach. This table captures those original individual ideas prior to merging into the single approved design in §4.3.*

| Member | Original Idea / Approach Proposed | Notes |
|---|---|---|
| Member 1 | | |
| Member 2 | | |
| Member 3 | | |
| Member 4 | | |

---

## Appendix — RTL Snapshot(s)

> **[RESERVED SPACE FOR RTL CODE SNAPSHOT(S) — insert screenshots or fenced code blocks of the actual RTL modules here, e.g. Address Decoder, Round Robin Arbiter, Crossbar, FIFOs]**

```verilog
// <insert RTL snapshot / module code here>
```