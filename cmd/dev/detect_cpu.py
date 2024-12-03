import subprocess
import platform

def get_cpu_info():
    # Check if we're on macOS
    if platform.system() != "Darwin":
        return "Not a Mac system"
    
    try:
        # Get CPU brand string
        cmd = "sysctl -n machdep.cpu.brand_string"
        cpu_brand = subprocess.check_output(cmd.split()).decode().strip()
        
        # Get architecture
        arch = platform.machine()
        
        # Get more detailed CPU info
        cpu_features = subprocess.check_output("sysctl -n machdep.cpu.features".split()).decode().strip()
        
        return {
            "CPU Brand": cpu_brand,
            "Architecture": arch,
            "CPU Features": cpu_features,
            "Compiler Flag": "-mcpu=apple-m1" if "Apple M1" in cpu_brand else 
                           "-mcpu=apple-m2" if "Apple M2" in cpu_brand else 
                           "-mcpu=apple-m1"  # default fallback
        }
    except subprocess.CalledProcessError as e:
        return f"Error running sysctl: {e}"
