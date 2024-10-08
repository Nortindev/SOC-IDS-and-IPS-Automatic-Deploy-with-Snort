# SOC-IDS-IPS-Automatic-Deploy-with-Snort
This project provides a step-by-step guide to install and configure Snort IDS/IPS on a VPS. It includes setting up detection rules, managing them with PulledPork, and testing Snort using real-world malware traffic. Ideal for anyone looking to implement or enhance network intrusion detection and prevention.

---

## Step 1: Register for Snort

1. Register an account on Snort's official site and confirm your email.
   - [Snort Registration](https://www.snort.org/users/sign_in)

---

## Step 2: Update and Upgrade Your VPS

1. Login to your VPS and update all packages:
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y

# Snort Installation and Configuration Guide

## Step 3. Install Snort

1. Create a directory for Snort:

    ```bash
    mkdir snort
    ```

2. Install required libraries using the script provided on this github! This script will automatically install Snort and all its required libraries, and also change the necessary configuration file with your network device detail.

    ```bash
    curl -O https://raw.githubusercontent.com/Nortindev/SOC-IDS-and-IPS-Automatic-Deploy-with-Snort/refs/heads/main/snort_install.sh ; bash snort_install.sh
    ```

3. Verify that Snort is installed:

    ```bash
    /usr/local/bin/snort -V
    ```
    
![Snort1](images/snort-1.jpeg)

## Step 4. Configure Snort Rules

1. Set up Snort configuration rules:

    ```bash
    snort -c /usr/local/etc/snort/snort.lua
    ```

2. Check your network settings:

    - The installation script will create a rule at boot to disable certain settings:

      ```bash
      /etc/systemd/system/disable-lro-gro.service
      ```

    - Identify your network interface (e.g., eth0):

      ```bash
      ip -c a
      ```

    - Check if receive-offload is enabled:

      ```bash
      sudo ethtool -k eth0 | grep receive-offload
      ```

## Step 5. Create a Rule to Detect ICMP Traffic

1. Create a directory for custom rules:

    ```bash
    sudo mkdir /usr/local/etc/rules
    ```

2. Create a new rules file:

    ```bash
    sudo nano /usr/local/etc/rules/local.rules
    ```

3. Add the following rule to detect ICMP traffic:

    ```bash
    alert icmp any any -> any any (msg: "ICMP Detected"; sid:1000001;)
    ```

    - Note: Rule SIDs must start from 1,000,001 as numbers below that are reserved by Snort.

## Step 6. Configure Snort with the New Rule

1. Apply the configuration and rule:

    ```bash
    snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules
    ```

2. Start Snort and print alerts:

    ```bash
    sudo snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules -i eth0 -A alert_fast
    ```

    ![Snort2](images/snort-2.jpeg)

3. Ping the server to generate alerts.

## Step 7. Persistent Rule Configuration

1. To avoid specifying the rule path every time, modify the Snort configuration file:

    ```bash
    sudo vim /usr/local/etc/snort/snort.lua
    ```

2. Search for `ips`:

    ```bash
    /ips
    ```

3. Enable built-in rules and include your custom rules:

    ```lua
    enable_builtin_rules = true
    include = "/usr/local/etc/rules/local.rules"
    ```

![Snort3](images/snort-3.jpeg)
    
4. Save the file.

## Step 8. Test Without Specifying Rule Path

1. Now you can run Snort without specifying the rule path:

    ```bash
    sudo snort -c /usr/local/etc/snort/snort.lua -i eth0 -A alert_fast
    ```

## Notes

- Ensure your Snort installation and configuration match your network setup.
- Always test your configuration to ensure it's functioning correctly.

# Snort Installation and Configuration Guide

## Step 9. Configure PulledPork for Rule Management

1. First, verify that PulledPork is installed and functioning:

    ```bash
    /usr/local/bin/pulledpork3/pulledpork.py -V
    ```

2. Edit the PulledPork configuration file:

    ```bash
    sudo nano /usr/local/etc/pulledpork3/pulledpork.conf
    ```

    - Comment out the `blocklist` section as it's not needed.
    - Uncomment `snort_path`.
    - Uncomment `local_rules` and remove the other rule paths.
    - Get the Oink Code from the Snort website.
  
![Snortoink](images/snort-oink.jpeg)

![Snort4](images/snort-4.jpeg)

3. Save the configuration file.

4. Create a directory to store and execute rules:

    ```bash
    sudo mkdir /usr/local/etc/so_rules
    ```

5. Execute PulledPork to download and apply rules:

    ```bash
    /usr/local/bin/pulledpork3/pulledpork.py -c /usr/local/etc/pulledpork3/pulledpork.conf
    ```

## Step 10. Modify PulledPork Python Script

1. Open the PulledPork Python script for editing:

    ```bash
    sudo vim /usr/local/bin/pulledpork3/pulledpork.py
    ```

2. Make necessary modifications to fit your environment and save the file.

![Snort5](images/snort-5.jpeg)

Change the version, on mine, the most recent version is 31470, change accordingly.

![Snort6](images/snort-6.jpeg)

![Snort7](images/snort-7.jpeg)

![Snort8](images/snort-8.jpeg)

Test it afterwards.

![Snort9](images/snort-9.jpeg)

## Step 11. Update Snort to Use PulledPork Rules

1. Modify Snort to point to PulledPork-generated rules. Open the Snort configuration file:

    ```bash
    sudo vim /usr/local/etc/snort/snort.lua
    ```

2. Make sure Snort points to the directory containing the PulledPork rules under the `IPS` section.

## Step 12. Run Snort with PulledPork Rules

1. Run Snort with the rules generated by PulledPork:

    ```bash
    snort -c /usr/local/etc/snort/snort.lua --plugin-path /usr/local/etc/so_rules/
    ```

## Step 13. Test Snort with a Malware PCAP

1. Create a directory for testing and go to it:

    ```bash
    mkdir ~/test ; cd ~/test
    ```

2. Download a test malware PCAP file:
   ```bash
     wget https://www.malware-traffic-analysis.net/2022/02/23/2022-02-23-traffic-analysis-exercise.pcap.zip
   ```
   
    **Password:** `infected_20220223`

   unzip it with
   
   ```bash
   unzip 2022-02-23-traffic-analysis-exercise.pcap.zip
   ```

4. Run Snort to test the PCAP file:

    ```bash
    snort -c /usr/local/etc/snort/snort.lua --plugin-path /usr/local/etc/so_rules/ -r ~/test/2022-02-23-traffic-analysis-exercise.pcap -A alert_fast -q > output.txt
    ```

From here, you can use Snort to log out the file, or simply redirect it to another file, here we will redirect to the file output.txt:


**Example Command to cut the information of the malicious PCAP** 

```bash
cat output.txt | cut -d "]" -f 3 | cut -d "[" -f 1 | cut -d "'" -f 2 | sort | uniq -c | sort
```

![Snortfinal](images/snort-final.jpeg)

## Notes

- Make sure PulledPork and Snort configurations align with your network and security needs.
- Regularly update your rules through PulledPork to ensure up-to-date threat detection.
- Always test the setup with sample malware or network traffic to verify functionality.





