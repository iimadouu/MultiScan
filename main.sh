#!/bin/bash

# Function to display ASCII art
display_ascii_art() {
    figlet -f standard "MultiScan"
    echo
    echo "Author: iimadouu"
    echo "ETH: 0x68699b4F7965A2347C2d61139856a2B7A40Bc41c"
    echo
    echo
}


# start scanning websites
scan_website() {
    display_ascii_art

    
    read -p "Enter the website domain (without HTTP/HTTPS): " website

    # Protocol HTTP or HTTPS
    echo "Choose the website protocol:"
    echo "1. HTTP"
    echo "2. HTTPS"
    read -p "Enter your choice: " protocol_choice
    echo

    if [ $protocol_choice -eq 1 ]; then
        protocol="http://"
    elif [ $protocol_choice -eq 2 ]; then
        protocol="https://"
    else
        echo "Invalid choice. Exiting..."
        return
    fi

    # Run the tools and append reports to HTML
    echo "Scanning website: $website"
    echo "Protocol: $protocol"
    echo

    # Create the HTML report file
    report_file="reports/pentest-report.html"
    echo "<html><head><title>Pentest Report</title></head><body>" > "$report_file"

    # Run SQLMap and append report to HTML
    echo "Running SQLMap..."
    sqlmap -u "$protocol$website" --crawl 5 --random-agent --level=3 --risk=1 --time-sec=40 --threads=6  --tamper=varnish.py,space2comment.py,between.py,randomcase --no-cast --timeout=170 --skip=Host,User-Agent --current-user --is-dba --privileges  --dbs --batch | tee -a "$report_file"

    # Run Commix and append report to HTML
    echo "Running Commix..."
    commix -u "$protocol$website" --all --batch | tee -a "$report_file"

    # Run Nikto and append report to HTML
    echo "Running Nikto..."
    nikto -h "$protocol$website" | tee -a "$report_file"

    # Run Dirb and append report to HTML
    echo "Running Dirb..."
    dirb "$protocol$website" | tee -a "$report_file"

    # Run Wfuzz and append report to HTML
    echo "Running Wfuzz..."
    wfuzz -w ~/MultiScan/wordlist/All_attack.txt  "$protocol$website/FUZZ" | tee -a "$report_file"

    # Run SSLScan and append report to HTML
    echo "Running SSLScan..."
    sslscan "$website" | tee -a "$report_file"

    # Run Wpscan and append report to HTML
    echo "Running Wpscan..."
    wpscan --url "$website" --batch | tee -a "$report_file"

    # Run Sslyze and append report to HTML
    echo "Running Sslyze..."
    sslyze --regular "$website" | tee -a "$report_file"

    # Run Skipfish and append report to HTML
    echo "Running Skipfish..."
    skipfish "$protocol$website" | tee -a "$report_file"

    # Run Wapiti and append report to HTML
    echo "Running Wapiti..."
    wapiti -u "$protocol$website"  | tee -a "$report_file"

    echo "Running SubFinder..."
    subfinder -d "$website"  | tee -a "$report_file"

    # Run XSSer and append report to HTML
    echo "Running XSSer..."
    xsser -u "$protocol$website" -c 100 --Cw 4 | tee -a "$report_file"

    # Run Nmap and append report to HTML
    echo "Running Nmap..."
    nmap -PN -sT --script vuln "$website" | tee -a "$report_file"

    # Close the HTML report file
    echo "</body></html>" >> "$report_file"

    echo
    echo "Scan completed. The consolidated HTML report is saved in: $report_file"
    echo
    echo "Please don't forget to help us improve, ETH : 0x68699b4F7965A2347C2d61139856a2B7A40Bc41c"
}

# Call the function to scan a website
scan_website
