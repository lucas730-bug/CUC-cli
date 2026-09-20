import os
import sys
import platform
import datetime
import subprocess

def run_cmd(command):
    """Safely handles shell commands and extracts string outputs cleanly."""
    try:
        return subprocess.check_output(command, shell=True, text=True, errors='ignore').strip()
    except Exception:
        return "N/A"

def inspect_system_properties():
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    computer_name = platform.node()
    
    # Establish dynamic directory layouts
    script_dir = os.path.dirname(os.path.abspath(__file__))
    results_dir = os.path.abspath(os.path.join(script_dir, "..", "results"))
    os.makedirs(results_dir, exist_ok=True)
    
    file_path = os.path.join(results_dir, f"osinspect_{computer_name}_{timestamp}.txt")
    
    output_lines = [
        "=======================================================",
        "         DEEP CORE SYSTEM OS INSPECTION AUDIT          ",
        "=======================================================",
        f"Computer Name : {computer_name}",
        f"Run Timestamp : {datetime.datetime.now().isoformat()}",
        "=" * 55,
        ""
    ]
    
    print(f"🔍 Compiling multi-tier hardware and software data pools...")

    # 1. CORE OS & KERNEL ENVIRONMENT
    output_lines.extend([
        "[1. CORE OS & KERNEL ENVIRONMENT]",
        f"  - Operating System   : {platform.system()} {platform.release()}",
        f"  - Build Architecture : {platform.machine()} ({' '.join(platform.architecture())})",
        f"  - OS Kernel Version  : {platform.version()}",
        f"  - System Boot Time   : {run_cmd('wmic os get lastbootuptime | findstr [0-9]')}",
        f"  - Windows Directory  : {os.environ.get('SystemRoot', 'N/A')}",
        ""
    ])

    # 2. ADVANCED HARDWARE & PROCESSOR SPECS
    output_lines.extend([
        "[2. ADVANCED HARDWARE & PROCESSOR SPECS]",
        f"  - CPU Brand / Model  : {platform.processor()}",
        f"  - Physical Cores     : {run_cmd('wmic cpu get NumberOfCores | findstr [0-9]')}",
        f"  - Logical Threads    : {os.cpu_count()}",
        f"  - Base Clock Speed   : {run_cmd('wmic cpu get MaxClockSpeed | findstr [0-9]')} MHz",
        f"  - Motherboard Model  : {run_cmd('wmic baseboard get product,manufacturer | findstr /v \"Product\"')}",
        f"  - BIOS Build Config  : {run_cmd('wmic bios get name,version | findstr /v \"Name\"')}",
        ""
    ])

    # 3. COMPLETE HARDWARE RAM INVENTORY
    output_lines.append("[3. COMPLETE HARDWARE RAM INVENTORY]")
    ram_raw = run_cmd("wmic computersystem get TotalPhysicalMemory | findstr [0-9]")
    if ram_raw.isdigit():
        gb_ram = round(int(ram_raw) / (1024 ** 3), 2)
        output_lines.append(f"  - Total Physical RAM : {gb_ram} GB")
    else:
        output_lines.append(f"  - Total Physical RAM : Unable to calculate total capacity")
        
    # Query individual memory banks
    output_lines.append("  - Installed Stick Profiler:")
    sticks = run_cmd("wmic memorychip get BankLabel, Capacity, Speed, Manufacturer | findstr /v \"Capacity\"")
    for stick in sticks.splitlines():
        if stick.strip():
            output_lines.append(f"     ↳ {stick.strip()}")
    output_lines.append("")

    # 4. STORAGE VOLUME SPACE ANALYSIS
    output_lines.append("[4. STORAGE VOLUME SPACE ANALYSIS]")
    drives = run_cmd("wmic logicaldisk get caption, freespace, size, filesystem | findstr /v \"Caption\"")
    for drive in drives.splitlines():
        if drive.strip():
            # Cleanly divide multiple string parameters
            parts = drive.split()
            if len(parts) >= 3:
                letter = parts[0]
                fs_type = parts[1]
                # Convert bytes safely to GB values
                try:
                    free_gb = round(int(parts[2]) / (1024 ** 3), 1)
                    total_gb = round(int(parts[3]) / (1024 ** 3), 1) if len(parts) > 3 else 0
                    output_lines.append(f"  - Volume ({letter}) [{fs_type}] -> Total: {total_gb}GB | Free: {free_gb}GB")
                except ValueError:
                    output_lines.append(f"  - Volume ({letter}) -> {drive.strip()}")
    output_lines.append("")

    # 5. NETWORKING LOGICAL ADAPTER MATRIX
    output_lines.append("[5. NETWORKING LOGICAL ADAPTER MATRIX]")
    adapters = run_cmd("wmic nicconfig where IPEnabled=True get Description, IPAddress | findstr /v \"Description\"")
    for adapter in adapters.splitlines():
        if adapter.strip():
            output_lines.append(f"  - Active Card Link: {adapter.strip()}")
    output_lines.append("")

    # 6. ACTIVE BACKGROUND RUNNING PROCESSES (TOP 20 HOGS)
    output_lines.append("[6. ACTIVE BACKGROUND RUNNING PROCESSES (TOP 20)]")
    tasks = run_cmd("tasklist /nh")
    count = 0
    for task in tasks.splitlines():
        if task.strip() and count < 20:
            output_lines.append(f"  - PID Process Node: {task.strip()[:50]}")
            count += 1
    output_lines.append("")

    # 7. LOGGED CRITICAL CORE SYSTEM DRIVERS
    output_lines.append("[7. LOGGED CRITICAL CORE SYSTEM DRIVERS]")
    drivers = run_cmd("driverquery /nh")
    count = 0
    for driver in drivers.splitlines():
        if driver.strip() and count < 15:
            output_lines.append(f"  - Driver Core Module: {driver.strip()[:65]}")
            count += 1

    # Dump the massive data footprint dynamically to terminal screen
    for line in output_lines:
        print(line)

    # Permanent output commit write
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))
        
    print(f"\n=======================================================")
    print(f"💾 Extended Audit Complete! Data kept permanently.")
    print(f"📂 Saved Location: {file_path}")
    print(f"=======================================================")

if __name__ == "__main__":
    inspect_system_properties()
