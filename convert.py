from pathlib import Path

data = Path("program.bin").read_bytes()

# Pad to a multiple of 4 bytes
while len(data) % 4:
    data += b"\x00"

with open("program.mem", "w") as f:
    for i in range(0, len(data), 4):
        word = int.from_bytes(data[i:i+4], "little")
        f.write(f"{word:08x}\n")

print("Created program.mem")