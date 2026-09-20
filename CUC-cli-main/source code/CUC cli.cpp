#include <iostream>
#include <string>
#include <cstdlib>   // For std::system
#include <filesystem> // Requires C++17 or newer

namespace fs = std::filesystem;

// ANSI Color Codes (Purple & Violet Theme)
#define RESET         "\033[0m"
#define BOLD          "\033[1m"
#define DEEP_PURPLE   "\033[38;5;129m"   // Dark, rich purple
#define PURPLE        "\033[35m"          // Standard Purple/Magenta
#define VIOLET        "\033[38;5;141m"   // Light, electric violet
#define BRIGHT_VIOLET "\033[38;5;177m"   // High-intensity violet accents
#define DARK_GRAY     "\033[90m"          // High-contrast border color
#define RED           "\033[31m"          // Standard Red
#define DARK_PLUM     "\033[38;5;53m"    // A very deep, dark wine-purple
#define ARMY_GREEN    "\033[38;5;58m"    // Muted, dark olive-toned green
#define NIGHT_PURPLE  "\033[38;5;239m"   // Muted, dark grayish-purple

// Clears the Windows terminal screen using "cls"
void clearScreen() {
    std::system("cls");
}

// Function to display the purple themed custom banner
void displayBanner() {
    std::cout << DARK_GRAY << "==========================================================" << RESET << "\n";
    std::cout << DEEP_PURPLE << BOLD << "   ____ _   _  ____            ____ _     ___ " << RESET << "\n";
    std::cout << DEEP_PURPLE << BOLD << "  / ___| | | |/ ___|          / ___| |   |_ _|" << RESET << "\n";
    std::cout << PURPLE << BOLD      << " | |   | | | | |             | |   | |    | | " << RESET << "\n";
    std::cout << PURPLE << BOLD      << " | |___| |_| | |___          | |___| |___ | | " << RESET << "\n";
    std::cout << VIOLET << BOLD      << "  \\____|\\___/ \\____|          \\____|_____|___|" << RESET << "\n";
    std::cout << DARK_GRAY << "----------------------------------------------------------" << RESET << "\n";
    std::cout << VIOLET << BOLD      << "        [ For forgive after there death ]" << RESET << "\n";
    std::cout << DARK_GRAY << "==========================================================" << RESET << "\n\n";
}

// Portable helper function that searches the adjacent "scripts" directory
void executeToolFile(const std::string& fileName) {
    clearScreen();

    // Looks for a folder named "scripts" right next to this running program
    fs::path scriptFolder = "scripts";
    fs::path filePath = scriptFolder / fileName;

    std::cout << PURPLE << BOLD << "--- Launching: " << fileName << " ---" << RESET << "\n\n";

    // Checks if the target file actually exists inside the adjacent scripts/ folder
    if (fs::exists(filePath)) {
        std::string command = "";
        std::string ext = filePath.extension().string();

        // FIX: Prepend the precise language interpreter wrapper so Windows never drops sub-threads
        if (ext == ".py") {
            command = "python \"" + filePath.string() + "\"";
        } else if (ext == ".vbs") {
            command = "cscript //nologo \"" + filePath.string() + "\"";
        } else if (ext == ".bat") {
            command = "call \"" + filePath.string() + "\"";
        } else {
            // Direct native execution fallback for compiled binaries (.exe)
            command = "\"" + filePath.string() + "\"";
        }

        // Executes the target command line matrix cleanly
        std::system(command.c_str());
    } else {
        std::cout << RED << "[!] Error: File not found inside the 'scripts' folder." << RESET << "\n";
        std::cout << DARK_GRAY << "Missing target: " << fs::absolute(filePath) << RESET << "\n";
    }

    std::cout << DARK_GRAY << "\n\nPress Enter to return to menu..." << RESET;
    std::cin.get();
}

int main() {
    std::string choice;

    while (true) {
        clearScreen();
        displayBanner();

        // 12 Tools organized in your side-by-side Windows CLI layout
        std::cout << RED << "(1) "  << RESET << DARK_PLUM << "Tool One (Ping Test)       " << RESET << RED << "(7) "  << RESET << DARK_PLUM << "Tool Seven (IP Check)"   << RESET << std::endl;
        std::cout << RED << "(2) "  << RESET << DARK_PLUM << "Tool Two (Traceroute)      " << RESET << RED << "(8) "  << RESET << DARK_PLUM << "Tool Eight (Subdomains)" << RESET << std::endl;
        std::cout << RED << "(3) "  << RESET << DARK_PLUM << "Tool Three (DNS Lookup)    " << RESET << RED << "(9) "  << RESET << DARK_PLUM << "Tool Nine (Whois Look)"  << RESET << std::endl;
        std::cout << RED << "(4) "  << RESET << DARK_PLUM << "Tool Four (Port Scan)      " << RESET << RED << "(10) " << RESET << DARK_PLUM << "Tool Ten (OS Inspect)"   << RESET << std::endl;
        std::cout << RED << "(5) "  << RESET << DARK_PLUM << "Tool Five (Banner Grab)    " << RESET << RED << "(11) " << RESET << DARK_PLUM << "Tool Eleven (SSL Check)" << RESET << std::endl;
        std::cout << RED << "(6) "  << RESET << DARK_PLUM << "Tool Six (Network Scan)    " << RESET << RED << "(12) " << RESET << DARK_PLUM << "Tool Twelve (Subnet Calc)" << RESET << std::endl;
        std::cout << NIGHT_PURPLE << "       [q] " << "Quit CUC" << RESET << std::endl << std::endl;

        std::cout << ARMY_GREEN << BOLD << "Power/$user $-=> " << RESET;
        std::getline(std::cin, choice);

        if (choice == "q" || choice == "Q") {
            std::cout << DEEP_PURPLE << BOLD << "\n[!] Exiting CUC CLI. Connection closed.\n" << RESET;
            break;
        }

        // Standardized across your actual custom asset names & scripting engines
        if (choice == "1")       executeToolFile("ping_tool.bat");      // Your ping asset (source 7)
        else if (choice == "2")  executeToolFile("traceroute.vbs");     // Your traceroute asset (source 2)
        else if (choice == "3")  executeToolFile("dns_lookup.py");      // Your DNS script (source 12)
        else if (choice == "4")  executeToolFile("port.html");   // Your Port web application/script context
        else if (choice == "5")  executeToolFile("banner_grabber.py");  // Your banner grab asset (source 11)
        else if (choice == "6")  executeToolFile("network_scanner.vbs"); // Your network status asset (source 5)
        else if (choice == "7")  executeToolFile("ip_checker.bat");     // Your system/target IP asset (source 4)
        else if (choice == "8")  executeToolFile("subdomain_scanner.cmd");// Your subdomain ping asset (source 3)
        else if (choice == "9")  executeToolFile("whois_tool.bat");     // Your diagnostic core net-util whois asset
        else if (choice == "10") executeToolFile("os_inspect.py");      // Your deep hardware profiling asset (source 6)
        else if (choice == "11") executeToolFile("SSL_check.vbs");    // Your certificate TLS handshake asset (source 8)
        else if (choice == "12") executeToolFile("subnet_calculator.exe"); // Your compiled static C++ binary (source 10)
        else {
            continue;
        }
    }

    return 0;
}
