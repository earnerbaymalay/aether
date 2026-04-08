#!/data/data/com.termux/files/usr/bin/bash
echo "🛡️ EDGE-SENTINEL MASTER CONTROL"
echo "1) START Dashboard & AI"
echo "2) STOP all services"
echo "3) CHECK Status"
read -p "Select option: " opt

case $opt in
  1)
    cd ~/edge-sentinel && ./start.sh
    ;;
  2)
    cd ~/edge-sentinel && ./stop.sh
    ;;
  3)
    echo "AI Server: $(pgrep -f llama-server | xargs echo)"
    echo "Backend: $(pgrep -f uvicorn | xargs echo)"
    ;;
  *)
    echo "Invalid option"
    ;;
esac
