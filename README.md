# Lucas-albers-lz4 Python-m1

## How do I install these formulae?

`brew tap lucas-albers-lz4/python-m1;`
`brew install lucas-albers-lz4/python-m1/python@3.12.7;`

Or `brew tap lucas-albers-lz4/python-m1` and then `brew install <formula>`.

Or, in a [`brew bundle`](https://github.com/Homebrew/homebrew-bundle) `Brewfile`:

```ruby
tap "lucas-albers-lz4/python-m1"
brew "<formula>"
```

## Python 3.12.7 Apple Silicon Optimization

### Overview
Modified Homebrew formula for Python 3.12.7 specifically optimized for Apple Silicon (M1/M2) processors. This version includes hardware-specific optimizations that will **only work on Apple Silicon Macs**.

### Key Changes
```ruby
cflags.concat %w[
  -mcpu=apple-m1    # Target Apple Silicon
  -flto=thin        # Link Time Optimization
  -ftree-vectorize  # Enable vectorization
  -fvectorize
  -fslp-vectorize
  -falign-functions=32
  -fomit-frame-pointer
  -ffast-math
]
```

### Compiler Flags Comparison
#### Stock Python
```bash
-fno-strict-overflow -Wsign-compare -Wunreachable-code -fno-common -dynamic -DNDEBUG -g -O3 -Wall -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk
```

#### Optimized Python
```bash
-fno-strict-overflow -Wsign-compare -Wunreachable-code -fno-common -dynamic -DNDEBUG -g -O3 -Wall -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk -mcpu=apple-m1 -flto=thin -ftree-vectorize -fvectorize -fslp-vectorize -falign-functions=32 -fomit-frame-pointer
```

### Important Notes
⚠️ This formula is specifically for Apple Silicon Macs and should not be used on Intel-based systems.

⚠️ Known Test Failures (same as stock Python):
```
4 tests failed:
- test_site
- test_sys
- test_sysconfig
- test_venv
```

### Benefits
- Optimized for M1/M2 architecture
- Enhanced vectorization
- Improved floating-point performance
- Better function alignment for M1/M2 cache

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
