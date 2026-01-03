`timescale 1ps/1ps
module fp_adder (
    input wire [31:0] a, b,
    output wire [31:0] s
);
    //Parnia Rezaei 402101793
    //sign detection:
    wire sign_A, sign_B;
    assign sign_A = a[31];
    assign sign_B = b[31];

    //Exponent detection:
    wire [7:0] exponent_A, exponent_B;
    assign exponent_A = (a[30:23] == 8'b0) ? 1 : a[30:23];
    assign exponent_B = (b[30:23] == 8'b0) ? 1 : b[30:23];

    //Hidden Bit:
    wire hidden_A, hidden_B;
    assign hidden_A = (a[30:23] == 8'b0) ? 0 : 1;
    assign hidden_B = (b[30:23] == 8'b0) ? 0 : 1;

    //Fraction detection: (Round, Gaurd)
    wire [25:0] fraction_A, fraction_B;
    assign fraction_A = {hidden_A, a[22:0], 2'b0};
    assign fraction_B = {hidden_B, b[22:0], 2'b0};

    //Comparing exponents:
    wire exp_A_is_bigger;
    assign exp_A_is_bigger = (exponent_A > exponent_B) ? 1 : 0;
    //Compute abs(exponent_A - exponent_B):
    wire [8:0] difference;
    assign difference = (exp_A_is_bigger) ? ({1'b0, exponent_A} - {1'b0, exponent_B}) : ({1'b0, exponent_B} - {1'b0, exponent_A});
    //Update fractions:
    wire [25:0] fraction_A1, fraction_B1, fraction_Comparator;
    wire sticky;
    assign fraction_A1 = (exp_A_is_bigger) ? (fraction_A) : (fraction_A >> difference);
    assign fraction_B1 = (exp_A_is_bigger) ? (fraction_B >> difference) : (fraction_B);
    assign fraction_Comparator = (exp_A_is_bigger) ? (fraction_B1 << difference) : (fraction_A1 << difference);
    assign sticky = (exp_A_is_bigger) ? ((fraction_B == fraction_Comparator) ? 0 : 1) : ((fraction_A == fraction_Comparator) ? 0 : 1);
    //New Fractions:
    wire [26:0] F_A, F_B;
    assign F_A = (exp_A_is_bigger) ? {fraction_A1, 1'b0} : {fraction_A1, sticky};
    assign F_B = (exp_A_is_bigger) ? {fraction_B1, sticky} : {fraction_B1, 1'b0};

    //Main Part: (Adder)
    wire [28:0] sum;
    wire sign;
    wire [27:0] magnitude;
    wire [28:0] magnitude_A, magnitude_B;

    assign magnitude_A = (sign_A) ? (-{2'b0, F_A}) : ({2'b0, F_A});
    assign magnitude_B = (sign_B) ? (-{2'b0, F_B}) : ({2'b0, F_B});
    assign sum = magnitude_A + magnitude_B;
    assign sign = sum[28];
    assign magnitude = (sign) ? (~sum[27:0] + 1) : sum[27:0];
    
    wire [7:0] exp;
    assign exp = (exp_A_is_bigger) ? (exponent_A  + 1) : (exponent_B + 1);
    //leading one detection:
    wire [7:0] shift;
    assign shift = (magnitude[27]) ? 0 :
                   (magnitude[26]) ? 1 :
                   (magnitude[25]) ? 2 :
                   (magnitude[24]) ? 3 :
                   (magnitude[23]) ? 4 :
                   (magnitude[22]) ? 5 :
                   (magnitude[21]) ? 6 :
                   (magnitude[20]) ? 7 :
                   (magnitude[19]) ? 8 :
                   (magnitude[18]) ? 9 :
                   (magnitude[17]) ? 10 :
                   (magnitude[16]) ? 11 :
                   (magnitude[15]) ? 12 :
                   (magnitude[14]) ? 13 :
                   (magnitude[13]) ? 14 :
                   (magnitude[12]) ? 15 :
                   (magnitude[11]) ? 16 :
                   (magnitude[10]) ? 17 :
                   (magnitude[9]) ? 18 :
                   (magnitude[8]) ? 19 :
                   (magnitude[7]) ? 20 :
                   (magnitude[6]) ? 21 :
                   (magnitude[5]) ? 22 :
                   (magnitude[4]) ? 23 :
                   (magnitude[3]) ? 24 :
                   (magnitude[2]) ? 25 :
                   (magnitude[1]) ? 26 : 27;
    wire [7:0] finalShift = (shift < exp) ? (shift) : (exp - 1);
    wire [7:0] expo;
    assign expo = (shift < exp && magnitude != 0) ? (exp - finalShift) : 0;
    wire [27:0] newFrac = magnitude << finalShift;
    wire [24:0] fraction = (newFrac[3:0] < 4'b1000) ? {1'b0, newFrac[27:4]} :
                        (newFrac[3:0] == 4'b1000 ? (newFrac[27:4] + newFrac[4]) : (newFrac[27:4] + 1));
    wire shiftRight = (fraction[24]) ? 1 : 0;
    wire [7:0] finalExponent = expo + shiftRight;
    wire [24:0] f1 = (shiftRight) ? (fraction >> 1) : fraction;
    wire [22:0] finalFraction = f1[22:0];
    assign s = {sign, finalExponent, finalFraction};
endmodule