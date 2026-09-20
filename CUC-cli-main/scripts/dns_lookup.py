import os
import sys
import datetime
import dns.resolver

def lookup_all_dns(domain):
    """
    Performs a comprehensive DNS lookup across all major record types
    and saves the combined details to a results file.
    """
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    results_dir = os.path.abspath(os.path.join(script_dir, "..", "results"))
    os.makedirs(results_dir, exist_ok=True)
    
    filename = f"dnslookup_{domain}_{timestamp}.txt"
    file_path = os.path.join(results_dir, filename)
    
    output_lines = [
        f"Comprehensive DNS Lookup Results",
        f"Domain: {domain}",
        f"Timestamp: {datetime.datetime.now().isoformat()}",
        "=" * 50,
        ""
    ]

    # The core record types to scan for maximum information
    record_types = {
        'A': 'IPv4 Addresses',
        'AAAA': 'IPv6 Addresses',
        'MX': 'Mail Servers',
        'TXT': 'Text Records (SPF, DKIM, Verification)',
        'NS': 'Name Servers',
        'CNAME': 'Canonical Name (Aliases)',
        'SOA': 'Start of Authority (Zone Info)',
        'SRV': 'Service Locators'
    }
    
    print(f"\n🔍 Running full DNS scan for: {domain}...\n")
    
    for r_type, description in record_types.items():
        try:
            answers = dns.resolver.resolve(domain, r_type)
            
            section_header = f"--- {r_type} Records ({description}) ---"
            print(section_header)
            output_lines.append(section_header)
            
            for rdata in answers:
                record_str = f"  ↳ {rdata.to_text()}"
                print(record_str)
                output_lines.append(record_str)
                
            print() # Print empty line for terminal spacing
            output_lines.append("") 
            
        except (dns.resolver.NoAnswer, dns.resolver.NoNameservers):
            # Normal behavior if a domain simply doesn't use this specific type
            continue
        except dns.resolver.NXDOMAIN:
            err = f"❌ Error: The domain {domain} does not exist."
            print(err)
            output_lines.append(err)
            break
        except dns.resolver.Timeout:
            err = f"⏳ Timeout querying {r_type} records."
            print(err)
            output_lines.append(err)
        except Exception as e:
            err = f"⚠️ Could not resolve {r_type}: {e}"
            print(err)
            output_lines.append(err)
            
    # Save everything to the file
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))
        
    print(f"💾 Comprehensive report successfully saved to:\n📂 {file_path}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        target_domain = sys.argv[1].strip()
    else:
        target_domain = input("Enter the domain name (e.g., google.com): ").strip()

    if target_domain:
        lookup_all_dns(target_domain)
    else:
        print("No domain entered. Exiting.")
