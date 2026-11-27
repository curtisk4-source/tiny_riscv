from pathlib import Path

# Always use the directory containing this script
BASE_DIR = Path(__file__).resolve().parent

binary_file = BASE_DIR / "program.bin"
memory_file = BASE_DIR / "program.mem"

# Read compiled binary
data = binary_file.read_bytes()

# Pad to a multiple of 4 bytes
while len(data) % 4:
	data += b"\x00"

# Convert little-endian bytes into 32-bit instruction words
with open(memory_file, "w") as f:
	for i in range(0, len(data), 4):
		word = int.from_bytes(data[i:i+4], "little")
		f.write(f"{word:08x}\n")

print(f"Created: {memory_file}")
print(f"Instructions: {len(data) // 4}")
