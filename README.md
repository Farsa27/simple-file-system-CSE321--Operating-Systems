# SimpleFS: A Minimal Disk-Image File System in C

SimpleFS is a small, Unix-style file system that lives inside a single disk-image file. It comes with two command-line tools:

- **`simplefs_builder`** formats a new 256 KB disk image with a superblock, allocation bitmaps, an inode table and a root directory.
- **`simplefs_adder`** copies a regular file from the host machine into the image, allocating an inode, data blocks and a directory entry for it.

This was an individual lab term project for **CSE321: Operating Systems** at BRAC University (2026). The course provided the program skeleton (argument parsing and file I/O scaffolding); I implemented the file-system logic: superblock and root-directory initialisation, bitmap-based allocation, inode and directory management, and block-level data copying.

## Disk layout

The image is 64 blocks of 4096 bytes each.

| Block(s) | Contents |
|---|---|
| 0 | Superblock: magic number `0x53465331`, block size, block and inode counts, and the location of every region |
| 1 | Inode bitmap: one bit per inode (32 inodes) |
| 2 | Data bitmap: one bit per data block (60 blocks) |
| 3 | Inode table: 32 inodes × 128 bytes |
| 4–63 | Data region; block 4 holds the root directory |

**Inode (128 bytes):** type (file or directory), link count, size in bytes, and three direct block pointers.
**Directory entry (64 bytes):** inode number, type, and a null-terminated name of up to 58 characters.

## Features

- Formats a fresh image with a valid superblock and a root directory containing `.` and `..`.
- First-fit allocation of free inodes and data blocks using the bitmaps.
- Rejects duplicate filenames, oversized files, over-long names and invalid images.
- Zero-byte files take an inode but no data blocks.
- The unused tail of a partly filled block is zero-filled, so no stale data leaks into the image.
- Updates the root directory size as each entry is added.

## Build

Requires `gcc` (or any C11 compiler) and `make`.

```bash
make            # builds simplefs_builder and simplefs_adder
make clean      # removes the binaries and any .img files
```

The code compiles cleanly with `-Wall -Wextra -std=c11`.

## Usage

```bash
./simplefs_builder --image disk.img
./simplefs_adder --input disk.img --file notes.txt
```

Example session:

```text
$ ./simplefs_builder --image disk.img
SimpleFS image created successfully: disk.img

$ ./simplefs_adder --input disk.img --file a.txt
a.txt added successfully to disk.img

$ ./simplefs_adder --input disk.img --file b.bin        # 9,000 bytes, uses 3 blocks
b.bin added successfully to disk.img

$ ./simplefs_adder --input disk.img --file a.txt
Error: file already exists in SimpleFS.

$ ./simplefs_adder --input disk.img --file big.bin      # 13,000 bytes
Error: file is too large for SimpleFS.
```

## How it works

**Builder**
1. Writes 64 zeroed blocks to create the image.
2. Fills in the superblock with the layout constants.
3. Marks inode 1 (the root) and data block 4 (the root's directory block) as used.
4. Writes the root inode as a directory with two links and size 128 bytes.
5. Writes the `.` and `..` entries, both pointing to the root.

**Adder**
1. Validates the arguments, the filename length and the image's magic number.
2. Calculates how many 4 KB blocks the file needs (zero for an empty file).
3. Checks the root directory for a duplicate name.
4. Finds a free inode and the required data blocks with a first-fit bitmap search.
5. Finds a free slot in the root directory.
6. Copies the file into its blocks using zero-filled buffers.
7. Writes the new inode, updates both bitmaps, adds the directory entry and increases the root directory's size.

## Limitations

These limits come from the project specification:

- Maximum file size is 12,288 bytes (three direct blocks, no indirect blocks).
- Only a flat root directory is supported; there are no subdirectories.
- Up to 31 files, limited by the number of free inodes.
- Files can be added but not read back, listed, or deleted with these tools.

## Project structure

```text
.
├── Makefile
├── README.md
└── src
    ├── simplefs.h            # on-disk structures and layout constants
    ├── simplefs_builder.c    # formats a new image
    └── simplefs_adder.c      # adds a file to an image
```

## Author

**Fahrim Arabin Farsa**, Computer Science and Engineering, BRAC University
[GitHub](https://github.com/Farsa27) · [LinkedIn](https://www.linkedin.com/in/fahrim-farsa-a80b21266/)
