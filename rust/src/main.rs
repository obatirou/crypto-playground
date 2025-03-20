use std::env;

fn rot_word(word: &[u8]) -> Vec<u8> {
    let mut result = Vec::with_capacity(4);
    if word.len() == 1 {
        result.push(0);
        return result;
    } else {
        result.extend_from_slice(&word[1..]);
        result.push(word[0]);
    }
    result
}

fn hex_to_bytes(hex_str: &str) -> Vec<u8> {
    // Remove 0x prefix if present
    let clean_hex = hex_str.strip_prefix("0x").unwrap();
    // Convert hex string to bytes
    hex::decode(clean_hex).unwrap_or_default()
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 3 {
        eprintln!("Usage: {} <function> <args>", args[0]);
        std::process::exit(1);
    }

    let func_to_call = &args[1];

    if func_to_call == "RotWord" {
        let word = &args[2];

        // Take first 10 chars (excluding 0x prefix, so 4 bytes) - matching Python implementation
        let hex_prefix_len = if word.starts_with("0x") { 2 } else { 0 };
        let bytes_to_process = if word.len() >= 10 + hex_prefix_len {
            hex_to_bytes(&word[..10])
        } else {
            hex_to_bytes(word)
        };

        // Rotate word
        let rotated = rot_word(&bytes_to_process);

        // Convert back to hex with 0x prefix and append zeros
        let result_hex = hex::encode(&rotated);
        println!(
            "0x{}00000000000000000000000000000000000000000000000000000000",
            result_hex
        );
    } else {
        eprintln!("Unknown function: {}", func_to_call);
        std::process::exit(1);
    }
}
