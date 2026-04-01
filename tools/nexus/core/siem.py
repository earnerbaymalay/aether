import subprocess, os, re

def run_nmap(target):
    print(f"[*] Initiating AI-Augmented Scan on {target}...")
    try:
        # Runs a fast service scan
        result = subprocess.check_output(["nmap", "-sV", "--top-ports", "100", target], text=True)
        return result
    except Exception as e:
        return f"Error running nmap: {str(e)}"

def analyze_logs(log_path):
    if not os.path.exists(log_path):
        return f"Log file {log_path} not found."
    try:
        with open(log_path, 'r') as f:
            lines = f.readlines()
            # Return last 50 lines
            return "".join(lines[-50:])
    except Exception as e:
        return f"Error reading logs: {str(e)}"
