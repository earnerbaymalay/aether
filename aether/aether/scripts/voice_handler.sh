#!/data/data/com.termux/files/usr/bin/bash
# voice_handler.sh — Voice I/O for Aether (Whisper.cpp STT + Piper TTS)
# Usage: voice_handler.sh [listen|speak <text>|setup|status|test]

VOICE_DIR="$HOME/aether/voice"
AUDIO_FILE="$VOICE_DIR/recording.wav"
TRANSCRIPT_FILE="$VOICE_DIR/transcript.txt"

mkdir -p "$VOICE_DIR"

# ============================================================
# DETECTION
# ============================================================

detect_audio_system() {
  if command -v termux-microphone-record &>/dev/null; then
    echo "termux"
  elif command -v arecord &>/dev/null; then
    echo "alsa"
  elif command -v rec &>/dev/null; then
    echo "sox"
  else
    echo "none"
  fi
}

detect_whisper() {
  if [ -f "$HOME/whisper.cpp/main" ] && [ -f "$HOME/whisper.cpp/models/ggml-base.en.bin" ]; then
    echo "installed"
  elif [ -f "$HOME/whisper.cpp/main" ]; then
    echo "partial"  # Binary exists but no model
  else
    echo "none"
  fi
}

detect_piper() {
  if command -v piper &>/dev/null; then
    echo "installed"
  elif [ -d "$HOME/piper" ] && [ -f "$HOME/piper/piper" ]; then
    echo "installed"
  else
    echo "none"
  fi
}

# ============================================================
# SPEECH-TO-TEXT
# ============================================================

record_audio() {
  local duration="${1:-10}"
  local system
  system=$(detect_audio_system)

  case "$system" in
    termux)
      echo "🎤 Recording for ${duration}s (Termux API)..."
      termux-microphone-record -l "$duration" -f "$AUDIO_FILE" 2>/dev/null
      ;;
    alsa)
      echo "🎤 Recording for ${duration}s (ALSA)..."
      arecord -d "$duration" -f S16_LE -r 16000 "$AUDIO_FILE" 2>/dev/null
      ;;
    sox)
      echo "🎤 Recording for ${duration}s (SoX)..."
      rec -d "$duration" "$AUDIO_FILE" 2>/dev/null
      ;;
    *)
      echo "❌ No audio recording system found"
      echo "Install: pkg install termux-api  (for Termux API)"
      echo "   Or:   pkg install sox  (for SoX)"
      return 1
      ;;
  esac

  if [ -f "$AUDIO_FILE" ] && [ -s "$AUDIO_FILE" ]; then
    echo "✓ Recording saved: $(du -h "$AUDIO_FILE" | cut -f1)"
    return 0
  else
    echo "❌ Recording failed"
    return 1
  fi
}

transcribe_audio() {
  local whisper_status
  whisper_status=$(detect_whisper)

  if [ "$whisper_status" = "none" ]; then
    echo "❌ Whisper.cpp not installed"
    echo "Run: voice_handler.sh setup"
    return 1
  fi

  if [ "$whisper_status" = "partial" ]; then
    echo "⚠ Whisper.cpp binary exists but model not downloaded"
    echo "Run: voice_handler.sh setup"
    return 1
  fi

  if [ ! -f "$AUDIO_FILE" ]; then
    echo "❌ No recording found. Record first: voice_handler.sh listen"
    return 1
  fi

  echo "🧠 Transcribing with Whisper.cpp..."
  
  # Run Whisper.cpp
  local output
  output=$("$HOME/whisper.cpp/main" \
    -m "$HOME/whisper.cpp/models/ggml-base.en.bin" \
    -f "$AUDIO_FILE" \
    -t 4 \
    --output-txt \
    --no-timestamps \
    2>/dev/null)

  if [ -n "$output" ]; then
    echo "$output" > "$TRANSCRIPT_FILE"
    echo "✓ Transcription complete:"
    echo "  \"$output\""
    return 0
  else
    echo "❌ Transcription failed"
    return 1
  fi
}

listen_and_transcribe() {
  echo "=== Voice Input ==="
  echo ""
  
  # Record
  if ! record_audio 15; then
    return 1
  fi
  
  echo ""
  
  # Transcribe
  if transcribe_audio; then
    echo ""
    echo "Use this transcript in your session."
    cat "$TRANSCRIPT_FILE"
    return 0
  else
    return 1
  fi
}

# ============================================================
# TEXT-TO-SPEECH
# ============================================================

speak_text() {
  local text="$1"
  
  if [ -z "$text" ]; then
    echo "Usage: voice_handler.sh speak <text>"
    return 1
  fi

  local piper_status
  piper_status=$(detect_piper)

  if [ "$piper_status" = "none" ]; then
    echo "❌ Piper TTS not installed"
    echo "Run: voice_handler.sh setup"
    return 1
  fi

  echo "🔊 Speaking..."
  
  if command -v piper &>/dev/null; then
    echo "$text" | piper \
      --model en_US-lessac-medium \
      --output_file "$VOICE_DIR/output.wav" \
      2>/dev/null
  elif [ -f "$HOME/piper/piper" ]; then
    echo "$text" | "$HOME/piper/piper" \
      --model "$HOME/piper/en_US-lessac-medium.onnx" \
      --output_file "$VOICE_DIR/output.wav" \
      2>/dev/null
  fi

  if [ -f "$VOICE_DIR/output.wav" ]; then
    echo "✓ Audio generated: $(du -h "$VOICE_DIR/output.wav" | cut -f1)"
    echo "Play with: termux-media-player play $VOICE_DIR/output.wav"
    
    # Auto-play if termux-media-player available
    if command -v termux-media-player &>/dev/null; then
      termux-media-player play "$VOICE_DIR/output.wav" 2>/dev/null &
    fi
  else
    echo "❌ TTS generation failed"
    return 1
  fi
}

# ============================================================
# SETUP
# ============================================================

setup_voice() {
  echo "=== Voice I/O Setup ==="
  echo ""
  
  # Whisper.cpp (STT)
  echo "1. Whisper.cpp (Speech-to-Text)"
  if [ "$(detect_whisper)" = "none" ]; then
    echo "  Installing Whisper.cpp..."
    cd "$HOME" || return
    if [ ! -d "whisper.cpp" ]; then
      git clone https://github.com/ggerganov/whisper.cpp.git
    fi
    cd whisper.cpp || return
    make -j$(nproc) 2>&1 | tail -3
    
    echo "  Downloading base model (~140MB)..."
    bash models/download-ggml-model.sh base.en 2>/dev/null || \
      wget -q --show-progress -O models/ggml-base.en.bin \
        "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
    
    echo "  ✓ Whisper.cpp installed"
  else
    echo "  ✓ Already installed ($(detect_whisper))"
  fi
  
  echo ""
  
  # Piper (TTS)
  echo "2. Piper TTS (Text-to-Speech)"
  if [ "$(detect_piper)" = "none" ]; then
    echo "  Installing Piper..."
    
    # Try pip install first
    if command -v pip &>/dev/null; then
      pip install piper-tts 2>&1 | tail -3
      if command -v piper &>/dev/null; then
        echo "  ✓ Piper installed via pip"
      else
        echo "  ⚠ pip install didn't provide 'piper' command"
      fi
    else
      echo "  ⚠ pip not available. Install manually:"
      echo "    pip install piper-tts"
    fi
  else
    echo "  ✓ Already installed"
  fi
  
  echo ""
  
  # Audio recording
  echo "3. Audio Recording"
  local audio_system
  audio_system=$(detect_audio_system)
  
  case "$audio_system" in
    termux) echo "  ✓ Termux API available" ;;
    alsa)   echo "  ✓ ALSA (arecord) available" ;;
    sox)    echo "  ✓ SoX (rec) available" ;;
    *)
      echo "  ⚠ No recording system found"
      echo "  Install: pkg install termux-api  OR  pkg install sox"
      ;;
  esac
  
  echo ""
  echo "✓ Voice I/O setup complete"
}

# ============================================================
# STATUS
# ============================================================

show_status() {
  echo "=== Voice I/O Status ==="
  echo ""
  
  echo "Speech-to-Text (Whisper.cpp):"
  case "$(detect_whisper)" in
    installed) echo "  ✓ Installed" ;;
    partial)   echo "  ⚠ Binary installed, model missing" ;;
    none)      echo "  ❌ Not installed — run: voice_handler.sh setup" ;;
  esac
  
  echo ""
  echo "Text-to-Speech (Piper):"
  case "$(detect_piper)" in
    installed) echo "  ✓ Installed" ;;
    none)      echo "  ❌ Not installed — run: voice_handler.sh setup" ;;
  esac
  
  echo ""
  echo "Audio Recording:"
  case "$(detect_audio_system)" in
    termux) echo "  ✓ Termux API" ;;
    alsa)   echo "  ✓ ALSA (arecord)" ;;
    sox)    echo "  ✓ SoX (rec)" ;;
    none)   echo "  ❌ No audio system" ;;
  esac
  
  echo ""
  if [ -f "$TRANSCRIPT_FILE" ]; then
    echo "Last Transcript:"
    cat "$TRANSCRIPT_FILE"
  fi
}

# ============================================================
# TEST
# ============================================================

test_voice() {
  echo "=== Voice I/O Test ==="
  echo ""
  
  # Test TTS
  echo "1. Testing Text-to-Speech..."
  speak_text "Hello, this is Aether voice system test."
  echo ""
  
  # Test STT (if recording available)
  echo "2. Testing Speech-to-Text..."
  echo "  Say 'hello aether' clearly..."
  record_audio 3
  if [ -f "$AUDIO_FILE" ]; then
    transcribe_audio
  fi
  
  echo ""
  echo "✓ Test complete"
}

# ============================================================
# MAIN
# ============================================================

ACTION="${1:-status}"

case "$ACTION" in
  listen)
    listen_and_transcribe
    ;;
  speak)
    speak_text "${2:-}"
    ;;
  setup)
    setup_voice
    ;;
  status)
    show_status
    ;;
  test)
    test_voice
    ;;
  *)
    echo "Voice I/O for Aether"
    echo ""
    echo "Usage: voice_handler.sh [listen|speak|setup|status|test]"
    echo ""
    echo "Commands:"
    echo "  listen          - Record and transcribe speech"
    echo "  speak <text>    - Convert text to speech"
    echo "  setup           - Install Whisper.cpp + Piper"
    echo "  status          - Show voice system status"
    echo "  test            - Run voice I/O test"
    exit 1
    ;;
esac
