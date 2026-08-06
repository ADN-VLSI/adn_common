# Pipelined Memory Interface (PMI) Specification

## 1. Purpose

The Pipelined Memory Interface (PMI) is a synchronous request/response protocol for on-chip communication between one master and one slave.

PMI supports:

- pipelined requests,
- slave backpressure,
- multiple outstanding transactions,
- strictly in-order responses.

## 2. Signal Set

| Signal   | Direction | Width        | Description                           |
| -------- | --------- | ------------ | ------------------------------------- |
| `clk`    | Global    | 1            | Rising-edge clock                     |
| `arst_n` | Global    | 1            | Asynchronous active-low reset         |
| `maddr`  | M->S      | 1 to 32      | Naturally aligned address             |
| `mwe`    | M->S      | 1            | Write enable (1=write, 0=read)        |
| `mwdata` | M->S      | 8/16/32/64   | Write data                            |
| `mstrb`  | M->S      | DATA_WIDTH/8 | Byte write strobes                    |
| `mreq`   | M->S      | 1            | Request valid                         |
| `mgnt`   | S->M      | 1            | Request grant (request-channel ready) |
| `mack`   | S->M      | 1            | Response valid                        |
| `mrdata` | S->M      | DATA_WIDTH   | Read data                             |
| `mresp`  | S->M      | 1            | Response code                         |

## 3. Basic Handshakes and Terms

### 3.1 Request Acceptance

A request is accepted on a rising clock edge when all are true:

```text
arst_n && mreq && mgnt
```

Each accepted request creates one outstanding transaction.

### 3.2 Response Completion

A transaction completes when `mack` is asserted on a rising clock edge. Exactly one completion response is generated per accepted request.

### 3.3 Channel Independence

The request channel (`mreq`/`mgnt`) and response channel (`mack` + payload) are independent. A response can occur in the same cycle as a new request acceptance.

## 4. Reset Behavior

During reset (`arst_n=0`):

- `mreq=0`
- `mgnt=0`
- `mack=0`

All other signals are don't-care during reset.

## 5. Protocol Rules

### PR-1 Clocking

All protocol transfers are sampled on rising edges of `clk` while
`arst_n=1`.

### PR-2 Request Validity

Before asserting `mreq`, the master shall drive valid values for
`maddr`, `mwe`, `mwdata`, and `mstrb`.

### PR-3 Request Acceptance

A request is accepted only on cycles where `mreq=1` and `mgnt=1`.

### PR-4 Stable Request While Stalled

While `mreq=1` and `mgnt=0`, the master shall keep `maddr`, `mwe`,
`mwdata`, and `mstrb` stable.

### PR-5 Post-Handshake Update

After a request is accepted, the master may change request signals on the next cycle.

### PR-6 Backpressure

The slave shall throttle new requests only by deasserting `mgnt`.

### PR-7 Outstanding Transactions

Multiple outstanding transactions are allowed. Maximum depth is implementation-defined.

### PR-8 Continuous Grant

If `mgnt` remains asserted, the master may issue one accepted request per cycle.

### PR-9 One Response Per Request

Exactly one `mack` shall be generated for each accepted request.

### PR-10 In-Order Responses

Responses shall return in the same order as request acceptance order.

### PR-11 Read Response Payload

For read responses (`mwe=0` for the corresponding request), `mrdata` and `mresp` are valid when `mack=1`.

### PR-12 Write Response Payload

For write responses (`mwe=1` for the corresponding request), `mrdata` is don't-care and `mresp` indicates status.

### PR-13 Transaction Completion Point

A transaction is complete only when its `mack` is asserted.

### PR-14 Response Latency

No minimum or maximum response latency is required by PMI.

### PR-15 Byte Strobes

`mstrb` selects active write byte lanes. `mstrb==0` is legal and produces a no-op write.

### PR-16 Address Alignment

`maddr` shall be naturally aligned to the data bus width.

## 6. Response Encoding

| `mresp` | Meaning |
| ------- | ------- |
| 0       | OKAY    |
| 1       | ERROR   |

## 7. Timing Notes

- Read and write latencies are implementation-defined.
- A response may coincide with acceptance of another request.
- Request throughput can reach one request per cycle when `mgnt=1`
  continuously.

## 8. Reference Timing Examples

1. Single read transaction.

Description:
A single read request is accepted on a `mreq && mgnt` handshake, and one corresponding response is returned. `mrdata` is only meaningful on the cycle where `mack=1`.

![Single read](rd.png)

2. Single write transaction.

Description:
A write is accepted immediately (no stall), followed by exactly one response. This illustrates the minimal write flow: handshake, optional latency, then completion via `mack`.

![Single write](wr.png)

3. Read with backpressure and delayed response.

Description:
The master asserts `mreq` for a read, but `mgnt` is temporarily deasserted by the slave. Request fields remain stable during stall, then the request is accepted when `mgnt` returns high. The response arrives later with valid `mrdata` and `mresp` when `mack=1`.

![Read with backpressure](rd_w.png)

4. Write with backpressure.

Description:
The master issues a write request while the slave applies request-channel backpressure (`mgnt=0`). Address, write enable, data, and strobes remain stable until acceptance. A single completion response follows, with `mresp` indicating status and `mrdata` don't-care.

![Write with backpressure](wr_w.png)

5. Back-to-back transactions and simultaneous request/response activity.

Description:
Two requests are accepted on consecutive cycles while `mgnt=1`. A prior response (`mack=1`) overlaps with a new request acceptance, illustrating independent request and response channels and pipelined throughput.

![Back-to-back and overlap example](b2b.png)
