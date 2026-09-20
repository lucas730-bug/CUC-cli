import os
import sys
import socket
import datetime
import urllib.request

def grab_banners(target):
    """
    Connects to common ports on a target domain/IP to extract service version banners
    and saves the combined details to a results file.
    """
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Track paths identical to your DNS lookup tool
    script_dir = os.path.dirname(os.path.abspath(__file__))
    results_dir = os.path.abspath(os.path.join(script_dir, "..", "results"))
    os.makedirs(results_dir, exist_ok=True)
    
    filename = f"bannergrab_{target}_{timestamp}.txt"
    file_path = os.path.join(results_dir, filename)
    
    output_lines = [
        f"Service Banner Grabbing Results",
        f"Target Host: {target}",
        f"Timestamp: {datetime.datetime.now().isoformat()}",
        "=" * 50,
        ""
    ]
    
    # Resolve target domain to IP to ensure socket connectivity works cleanly
    print(f"\n🔍 Resolving host and running Banner Grabber for: {target}...\n")
    try:
        target_ip = socket.gethostbyname(target)
        header_msg = f"Target Resolved IP: {target_ip}"
        print(header_msg)
        output_lines.append(header_msg + "\n" + "-"*30 + "\n")
    except socket.gaierror:
        err = f"❌ Error: Unable to resolve host identity for '{target}'"
        print(err)
        output_lines.append(err)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write("\n".join(output_lines))
        return

    # Define standard ports to sweep for banner disclosures
    ports_to_check = {
        21: "FTP (File Transfer)",
        22: "SSH (Secure Shell)",
        23: "Telnet",
        25: "SMTP (Mail Server)",
        80: "HTTP (Web Server)",
        110: "POP3 (Mail Server)",
        143: "IMAP (Mail Server)",
        443: "HTTPS (Secure Web Server)",
    }
    
    socket.setdefaulttimeout(3.0) # Prevent long hangs on closed ports
    
    for port, service_desc in ports_to_check.items():
        section_header = f"--- Port {port} | {service_desc} ---"
        print(section_header)
        output_lines.append(section_header)
        
        # Special handling for Web Ports (80 / 443) to read HTTP response server headers safely
        if port in [80, 443]:
            protocol = "https" if port == 443 else "http"
            try:
                # Build connection request ignoring SSL verification steps for simplicity
                req = urllib.request.Request(f"{protocol}://{target}", headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req, timeout=3.0) as response:
                    server_header = response.headers.get('Server')
                    powered_by = response.headers.get('X-Powered-By')
                    
                    if server_header:
                        banner = f"  ↳ Server Software: {server_header}"
                    else:
                        banner = "  ↳ Connected successfully, but 'Server' header is hidden."
                        
                    if powered_by:
                        banner += f"\n  ↳ Technology Stack: {powered_by}"
                        
                    print(banner)
                    output_lines.append(banner)
            except Exception as e:
                # Catch protocol variations (like missing paths) but read raw response headers if thrown
                if hasattr(e, 'headers') and e.headers.get('Server'):
                    banner = f"  ↳ Server Software (via Error Status): {e.headers.get('Server')}"
                    print(banner)
                    output_lines.append(banner)
                else:
                    err_str = f"  ❌ Connection timed out or port closed."
                    print(err_str)
                    output_lines.append(err_str)
                    
        # Handling for classic stream ports (FTP, SSH, Mail) via TCP Sockets
        else:
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.connect((target_ip, port))
                
                # Read the initial service connection greetings up to 1024 bytes
                banner_raw = s.recv(1024)
                banner_clean = banner_raw.decode('utf-8', errors='ignore').strip()
                
                if banner_clean:
                    banner_str = f"  ↳ Banner: {banner_clean}"
                else:
                    banner_str = "  ↳ Connected successfully, but no implicit greeting banner was pushed."
                    
                print(banner_str)
                output_lines.append(banner_str)
                s.close()
            except Exception:
                err_str = f"  ❌ Connection timed out or port closed."
                print(err_str)
                output_lines.append(err_str)
                
        print() # UI line breaks
        output_lines.append("")

    # Commit all captured outputs to disk
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))
        
    print(f"💾 Banner details successfully saved to:\n📂 {file_path}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        target_host = sys.argv[1].strip()
    else:
        target_host = input("Enter target domain or IP (e.g., google.com): ").strip()

    if target_host:
        grab_banners(target_host)
    else:
        print("No target host entered. Exiting.")
