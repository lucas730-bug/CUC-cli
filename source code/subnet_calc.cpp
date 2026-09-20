#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <cmath>
#include <iomanip>
#include <fstream>
#include <ctime>

#ifdef _WIN32
#include <direct.h>
#include <windows.h>
#define GetCurrentDir _getcwd
#else
#include <unistd.h>
#define GetCurrentDir getcwd
#endif

// Converts dot-decimal string to 32-bit unsigned integer
unsigned int ipToLong(const std::string& ipStr) {
    std::stringstream ss(ipStr);
    std::string item;
    unsigned int ipLong = 0;
    int shift = 24;
    while (std::getline(ss, item, '.')) {
        ipLong += (std::stoul(item) << shift);
        shift -= 8;
    }
    return ipLong;
}

// Converts 32-bit unsigned integer back to dot-decimal string
std::string longToIp(unsigned int ipLong) {
    std::stringstream ss;
    ss << ((ipLong >> 24) & 0xFF) << "."
       << ((ipLong >> 16) & 0xFF) << "."
       << ((ipLong >> 8) & 0xFF) << "."
       << (ipLong & 0xFF);
    return ss.str();
}

// Generates a binary visualization string string
std::string getBinaryStream(unsigned int ipLong) {
    std::string s = "";
    for (int i = 31; i >= 0; i--) {
        s += ((ipLong >> i) & 1) ? "1" : "0";
        if (i % 8 == 0 && i != 0) s += ".";
    }
    return s;
}

std::string getTimestamp() {
    std::time_t t = std::time(nullptr);
    std::tm* now = std::localtime(&t);
    char buffer[20];
    std::strftime(buffer, sizeof(buffer), "%Y%m%d_%H%M%S", now);
    return std::string(buffer);
}

std::string getIsoTimestamp() {
    std::time_t t = std::time(nullptr);
    std::tm* now = std::localtime(&t);
    char buffer[30];
    std::strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%S", now);
    return std::string(buffer);
}

int main() {
    std::string ipInput;
    int cidr;

    std::cout << "=======================================================\n";
    std::cout << "               C++ SUBNET CALCULATOR                   \n";
    std::cout << "=======================================================\n";
    std::cout << "Enter Base IP Address (e.g., 192.168.1.1): ";
    std::cin >> ipInput;
    std::cout << "Enter Subnet Mask / CIDR (1-32): ";
    std::cin >> cidr;

    if (cidr < 1 || cidr > 32) {
        std::cerr << "❌ Error: Invalid CIDR range.\n";
        return 1;
    }

    // 1. Bitwise Arithmetic Calculations
    unsigned int ipLong = ipToLong(ipInput);
    unsigned int maskLong = (cidr == 0) ? 0 : (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;
    unsigned int wildcardLong = ~maskLong;
    unsigned int networkLong = ipLong & maskLong;
    unsigned int broadcastLong = networkLong | wildcardLong;

    unsigned int totalHosts = 0;
    unsigned int firstHost = 0;
    unsigned int lastHost = 0;

    if (cidr >= 31) {
        totalHosts = 0;
        firstHost = networkLong;
        lastHost = broadcastLong;
    } else if (cidr == 32) {
        totalHosts = 1;
        firstHost = ipLong;
        lastHost = ipLong;
    } else {
        totalHosts = broadcastLong - networkLong - 1;
        firstHost = networkLong + 1;
        lastHost = broadcastLong - 1;
    }

    // 2. Map folder paths dynamically to match layout structures
    std::string resultsDir = "..\\results";
#ifdef _WIN32
    // Create the results folder securely if missing via Windows API
    CreateDirectoryA(resultsDir.c_str(), NULL);
#endif

    std::string filename = resultsDir + "\\subnetcalc_" + ipInput + "_" + getTimestamp() + ".txt";

    // 3. Compile report metrics payload
    std::stringstream output;
    output << "=======================================================\n"
           << "            STRUCTURAL SUBNET CALCULATOR LOG           \n"
           << "=======================================================\n"
           << "Target Query  : " << ipInput << " /" << cidr << "\n"
           << "Calculation TS: " << getIsoTimestamp() << "\n"
           << "-------------------------------------------------------\n\n"
           << "  [+] CIDR Notation   : " << ipInput << "/" << cidr << "\n"
           << "  [+] Subnet Mask     : " << longToIp(maskLong) << "\n"
           << "  [+] Network Address : " << longToIp(networkLong) << "\n"
           << "  [+] Usable Range    : " << longToIp(firstHost) << " - " << longToIp(lastHost) << "\n"
           << "  [+] Broadcast Node  : " << longToIp(broadcastLong) << "\n"
           << "  [+] Usable Hosts    : " << totalHosts << "\n"
           << "  [+] Wildcard Mask   : " << longToIp(wildcardLong) << "\n"
           << "  [+] IP Binary Stream: " << getBinaryStream(ipLong) << "\n";

    // Print to screen terminal layout
    std::cout << "\n" << output.str() << "\n";

    // 4. Save results to the folder
    std::ofstream outFile(filename);
    if (outFile.is_open()) {
        outFile << output.str();
        outFile.close();
        std::cout << "=======================================================\n";
        std::cout << "💾 Report processing complete! Data kept permanently.\n";
        std::cout << "📂 Saved Path: " << filename << "\n";
        std::cout << "=======================================================\n";
    } else {
        std::cerr << "⚠️ Error: Unable to open file to save results.\n";
    }

    return 0;
}
