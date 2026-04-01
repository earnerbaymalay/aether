#!/usr/bin/env python3
import argparse
import subprocess
import sys
import requests
import os

API_URL = "http://127.0.0.1:5000"
API_TOKEN = os.environ.get("NEXUS_API_TOKEN", "dev-token-123")
HEADERS = {"Authorization": f"Bearer {API_TOKEN}", "Content-Type": "application/json"}

def check_api():
    try:
        return requests.get(f"{API_URL}/health", headers=HEADERS, timeout=2).status_code == 200
    except:
        return False

def start_hub(args):
    print("🚀 Starting Nexus AI Hub...")
    subprocess.Popen(["python3", "nexus_engine.py"])

def run_recon(args):
    if not check_api(): return print("❌ Error: Hub offline.")
    print(f"📡 Running Nmap on {args.target}...")
    scan = subprocess.run(["nmap", "-F", "-T4", args.target], capture_output=True, text=True)
    res = requests.post(f"{API_URL}/analyze", json={"module": "mobile-recon", "target": args.target, "scan_data": scan.stdout}, headers=HEADERS)
    print("\n🧠 AI Analysis:\n" + res.json().get("analysis", "Error"))

def run_sentinel(args):
    if not check_api(): return print("❌ Error: Hub offline.")
    print(f"🛡️ Sentinel parsing logs from: {args.target}...")
    
    try:
        with open(args.target, 'r') as f:
            logs = f.readlines()
        
        # Filter logic: Only extract anomalies
        anomalies = [line for line in logs if "Failed" in line or "invalid" in line]
        if not anomalies:
            return print("✅ No anomalies detected.")
            
        raw_data = "".join(anomalies[-10:]) # Send the last 10 suspicious events
        
        res = requests.post(f"{API_URL}/analyze", json={"module": "sentinel", "target": args.target, "scan_data": raw_data}, headers=HEADERS)
        print("\n🧠 AI Threat Assessment:\n" + res.json().get("analysis", "Error"))
        
    except FileNotFoundError:
        print(f"❌ Error: {args.target} not found.")

def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command")
    
    p_start = subparsers.add_parser("start")
    p_start.set_defaults(func=start_hub)
    
    p_recon = subparsers.add_parser("recon")
    p_recon.add_argument("-t", "--target", required=True)
    p_recon.set_defaults(func=run_recon)
    
    p_sentinel = subparsers.add_parser("sentinel")
    p_sentinel.add_argument("-t", "--target", required=True, help="Log file to analyze")
    p_sentinel.set_defaults(func=run_sentinel)

    args = parser.parse_args()
    if args.command is None: sys.exit(parser.print_help())
    args.func(args)

if __name__ == "__main__":
    main()
