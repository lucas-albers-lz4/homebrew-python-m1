## How do I install these formulae?

`brew tap lucas-albers-lz4/python-m1`

## Available Versions

### Standard Installation
```bash
brew install lucas-albers-lz4/python-m1/python@3.12
```
Python 3.12 uses `-mcpu=apple-m1` optimization on Apple Silicon.

### Keg-Only Installations
```bash
brew install lucas-albers-lz4/python-m1/python@3.13
brew install lucas-albers-lz4/python-m1/python@3.12.7
```

Current optimization levels:
- Python 3.13: `-mcpu=apple-m1`
- Python 3.12.7: `-mcpu=apple-m2`
- Python 3.12: `-mcpu=apple-m1`

These versions are installed as "keg-only", meaning they won't be automatically linked into your system paths. This is useful for:
- Testing new Python versions (3.13)
- Running specific version-dependent applications
- Comparing performance between versions
- Avoiding conflicts with the system Python

To use a keg-only version, either:
- Use the full path: `/usr/local/opt/python@3.13/bin/python3.13`
- Add to your PATH: `export PATH="/usr/local/opt/python@3.13/bin:$PATH"`
- Create a virtual environment with the specific version

## Features
- Hardware-specific performance improvements
- Compatible with Homebrew package management
- Configurable installation options
- Support for both linked and keg-only installations


## Python 3.12.7 Apple Silicon Optimization

### Overview
Modified Homebrew formula for Python 3.12.7 specifically optimized for Apple Silicon (M1/M2) processors. This version includes hardware-specific optimizations that will **only work on Apple Silicon Macs**.

### Key Changes
```
    if OS.mac?
      if Hardware::CPU.arm?
        # Optimization varies by version:
        # Python 3.12.7: apple-m2
        # Python 3.12: apple-m1
        # Python 3.13: apple-m1
        cflags.push("-mcpu=apple-m2")  # Example from 3.12.7
      end
```

### Apple currently supports cpu m1 and m2 processor's directly as of 2024
```bash
for flag in apple-m1 apple-m2 apple-m3 apple-latest; do
    clang -mcpu=$flag -c -x c /dev/null -o /dev/null && echo "$flag supported" || echo "$flag not supported"
done
apple-m1 supported
apple-m2 supported

```

### Notes
⚠️ This formula is specifically for Apple Silicon Macs.

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

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
