#include <iostream>
#include <vector>
#include <string>
#include <filesystem>

namespace fs = std::filesystem;

void startRepair() {
    std::cout << "\n==================================================" << std::endl;
    std::cout << "[!] ERROR: Critical files are missing or were moved!" << std::endl;
    std::cout << "[!] Please reinstall the application or run the repair tool." << std::endl;
    std::cout << "==================================================" << std::endl;
    
    // Add your actual file restoration / installer trigger logic here
}

int main() {
    // 1. Define the list of files and directories
    std::vector<std::string> requiredPaths = {
        "CUC_cli.scr",
        "results\\",
        "how to use\\",
        "About me\\",
        "source code\\",
        "scripts\\",
        "scripts\\whois_tool.bat",
        "scripts\\subnet_calculator.exe",
        "scripts\\traceroute.vbs",
        "scripts\\subdomain_scanner.cmd",
        "scripts\\SSL_check.vbs",
        "scripts\\port.html",
        "scripts\\ping_tool.bat",
        "scripts\\os_inspect.py",
        "scripts\\network_scanner.vbs",
        "scripts\\ip_checker.bat",
        "scripts\\dns_lookup.py",
        "scripts\\banner_grabber.py",
        "repair cli.exe",
		"source code\\CUC cli.cpp",
		"source code\\subnet_calc.cpp",
		"source code\\repair cli.cpp",
		"errors//",
		"install//"
		
    };

    bool repairNeeded = false;

    std::cout << "Verifying application integrity..." << std::endl;

    // 2. Loop through and check existence
    for (const auto& pathStr : requiredPaths) {
        fs::path targetPath(pathStr);

        if (!fs::exists(targetPath)) {
            std::cout << "[X] MISSING: " << pathStr << std::endl;
            repairNeeded = true; 
        } else {
            std::cout << "[O] OK: " << pathStr << std::endl;
        }
    }

    // 3. Handle the outcome
    if (repairNeeded) {
        startRepair();
        
        // Pause so the user can actually read the "Please Reinstall" warning
        std::cout << "\nPress Enter to exit..." << std::endl;
        std::cin.get();
    } else {
        std::cout << "\n[SUCCESS] Status: All files are intact!" << std::endl;
        std::cout << "Press Enter to exit..." << std::endl;
        
        std::cin.get(); // Pauses execution until the user presses Enter
    }

    return 0;
}
