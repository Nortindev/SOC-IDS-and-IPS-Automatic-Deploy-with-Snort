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

2. Install required libraries using the script provided.

3. Verify that Snort is installed:

    ```bash
    /usr/local/bin/snort -V
    ```

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

4. Save the file.

## Step 8. Test Without Specifying Rule Path

1. Now you can run Snort without specifying the rule path:

    ```bash
    sudo snort -c /usr/local/etc/snort/snort.lua -i eth0 -A alert_fast
    ```

## Notes

- Ensure your Snort installation and configuration match your network setup.
- Always test your configuration to ensure it's functioning correctly.

