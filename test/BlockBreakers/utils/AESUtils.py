# AES operates some of its transformation on GF(2^8).
# Its defined as GF(2^8) = {a₇x⁷ + a₆x⁶ + a₅x⁵ + a₄x⁴ + a₃x³ + a₂x² + a₁x + a₀ | aᵢ ∈ {0,1}}/(x⁸ + x⁴ + x³ + x + 1)
# in byte representation is [a₇, a₆, a₅, a₄, a₃, a₂, a₁, a₀]
# For example, x⁵ + x² + x + 1 is 00100111
# 0x8D is the last value of the sequence (256). It is put in the first position of the array to make the calculations easier.
# R_CON is defined as r_con(i) = Xⁱ mod (x⁸ + x⁴ + x³ + x + 1) with i beginning at 1
# Hence, it is multiplying the polynomial X by itself i times
# X is represented as 0x02 (000000010) in GF(2^8) and the irreducible polynomial is 0x11B
def calculate_r_con(num_values):
    # Initialize array with 0x8D
    # 0x8D is the last value of the sequence (256) but it is put in the first position
    # to make the calculations easier because 0x8D * 0x02 = 0x11A <=> 0x01 mod (0x11B) = r_con(1)
    r_con = [0x8D]

    # Calculate remaining values
    for i in range(1, num_values):
        # Multiply previous value by 0x02 (x)
        prev = r_con[i - 1]
        # Check if MSB is set (would overflow byte)
        if prev & 0x80:
            # Apply reduction with AES polynomial
            # Shift left and XOR with 0x11B
            next_val = ((prev << 1) ^ 0x11B) & 0xFF
        else:
            # Simple doubling
            next_val = (prev << 1) & 0xFF

        r_con.append(next_val)

    return r_con
