#!/bin/bash

echo "🚀 Setting up OpenVoice Voice Cloning Environment..."
echo "=================================================="

# Update system and install essential packages
echo "📦 Installing system dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y ffmpeg libsndfile1 build-essential cmake wget unzip

# Install CPU-only PyTorch and related packages optimized for Codespaces
echo "🔧 Installing PyTorch (CPU-only) and dependencies..."
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install core dependencies for audio processing and AI
echo "📚 Installing core Python dependencies..."
pip install librosa soundfile pydub scipy numpy matplotlib jupyter gradio ipywidgets
pip install langid faster-whisper tqdm inflect unidecode pypinyin jieba
pip install wavmark whisper-timestamped eng_to_ipa cn2an

# Clone OpenVoice repository
echo "📁 Cloning OpenVoice repository..."
if [ ! -d "OpenVoice" ]; then
    git clone https://github.com/myshell-ai/OpenVoice.git
fi
cd OpenVoice

# Install OpenVoice in editable mode
echo "⚙️ Installing OpenVoice..."
pip install -e .

# Create directories for models and outputs
mkdir -p checkpoints_v2 outputs resources

# Download OpenVoice V2 checkpoints
echo "📥 Downloading OpenVoice V2 model checkpoints..."
cd checkpoints_v2
if [ ! -f "checkpoints_v2_0417.zip" ]; then
    wget -c https://myshell-public-repo-hosting.s3.amazonaws.com/openvoice/checkpoints_v2_0417.zip
fi

# Extract checkpoints if not already extracted
if [ ! -d "base_speakers" ]; then
    echo "📂 Extracting model checkpoints..."
    unzip -q checkpoints_v2_0417.zip
    # Move contents up one level if needed
    if [ -d "checkpoints_v2" ]; then
        mv checkpoints_v2/* .
        rmdir checkpoints_v2
    fi
fi

cd ..

# Install MeloTTS for V2 functionality
echo "🎵 Installing MeloTTS..."
pip install git+https://github.com/myshell-ai/MeloTTS.git

# Download unidic for MeloTTS
echo "📖 Downloading language data for MeloTTS..."
python -m unidic download

# Create a simple run script
echo "📝 Creating launch script..."
cat > run_openvoice.sh << 'EOL'
#!/bin/bash
cd OpenVoice
echo "🎤 Launching OpenVoice Gradio Interface..."
echo "Access the interface at: http://localhost:7860"
python -m openvoice_app --share
EOL
chmod +x run_openvoice.sh

# Create a demo audio file upload directory
mkdir -p OpenVoice/user_audio

echo "✅ OpenVoice setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Upload your voice sample (10-30 seconds) to OpenVoice/user_audio/"
echo "2. Run: cd OpenVoice && python -m openvoice_app --share"
echo "3. Open the Gradio interface in your browser"
echo "4. Upload your audio sample and start voice cloning!"
echo ""
echo "🔧 Alternative launch methods:"
echo "   - Jupyter notebooks: jupyter notebook (then open demo_part1.ipynb or demo_part3.ipynb)"
echo "   - Direct script: ./run_openvoice.sh"
echo ""
echo "💡 Tips:"
echo "   - Use clear, noise-free audio samples for best results"
echo "   - 10-30 second samples work well"
echo "   - Supported formats: wav, mp3, flac, m4a"
