# FP-Adder: IEEE 754 Single-Precision Floating-Point Adder in Verilog

![Verilog](https://img.shields.io/badge/Verilog-RTL-blue) ![IEEE 754](https://img.shields.io/badge/IEEE-754-green) ![FPGA Ready](https://img.shields.io/badge/FPGA-Ready-red) ![License](https://img.shields.io/badge/License-MIT-yellow)

A clean, synthesizable Verilog implementation of a **32-bit single-precision floating-point adder** compliant with the **IEEE 754 standard**. Designed using **continuous assignment** for clarity and efficiency, suitable for academic use, FPGA prototyping, and ASIC digital arithmetic studies.

---

## 📋 **Features**
- ✅ **IEEE 754 single-precision (32-bit)** compliant
- ✅ Supports **normalized numbers**, rounding, and special cases (NaN, ±Inf, Zero)
- ✅ **Continuous assignment** (`assign`) based design
- ✅ **Fully synthesizable** for FPGA/ASIC
- ✅ **Self-checking testbench** with randomized and corner-case tests
- ✅ **Modular design** for easy extension (e.g., pipeline support, double precision)

---

## 🏗️ **Architecture Overview**
The adder follows the standard floating-point addition steps:
1. **Sign and exponent comparison**
2. **Mantissa alignment** (shifting)
3. **Mantissa addition/subtraction**
4. **Normalization** and **rounding**
5. **Output formatting**

### Block Diagram
    [ Input A ]       [ Input B ]
          |                 |
    [ Sign/Exp/Mant Split ] 
          |                 |
    [ Alignment Shift Unit ]
          |                 |
    [ Mantissa Adder/Subtractor ]
          |                 |
    [ Normalization & Rounding ]
          |                 |
       [ Output Z ]
