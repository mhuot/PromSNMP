# Ubuntu Setup for PromSNMP Demo Recording

Complete setup guide for recording the PromSNMP demo on Ubuntu using terminalizer.

## 1. Update System

```bash
sudo apt update && sudo apt upgrade -y
```

## 2. Install Basic Tools

```bash
sudo apt install -y curl wget git make jq
```

## 3. Install Node.js (for terminalizer)

```bash
# Install Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version
npm --version
```

## 4. Install Terminalizer

```bash
sudo npm install -g terminalizer

# Verify
terminalizer --version
```

## 5. Install GitHub CLI (gh)

```bash
# Add GitHub CLI repo
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt update
sudo apt install -y gh

# Authenticate with GitHub
gh auth login
```

## 6. Install Java 21 and Maven

```bash
# Install OpenJDK 21 and Maven
sudo apt install -y openjdk-21-jdk maven

# Verify
java -version
mvn -version
```

## 7. Install jenv (Java Version Manager)

```bash
# Clone jenv
git clone https://github.com/jenv/jenv.git ~/.jenv

# Add to shell (choose one based on your shell)
# For bash:
echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(jenv init -)"' >> ~/.bashrc
source ~/.bashrc

# For zsh:
echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(jenv init -)"' >> ~/.zshrc
source ~/.zshrc

# Find and register Java 21 (path varies by architecture)
JAVA_PATH=$(ls -d /usr/lib/jvm/java-21-openjdk-* 2>/dev/null | head -1)
jenv add "$JAVA_PATH"

# Or manually:
# ARM64: jenv add /usr/lib/jvm/java-21-openjdk-arm64
# AMD64: jenv add /usr/lib/jvm/java-21-openjdk-amd64

# Verify
jenv versions
```

## 8. Install Docker

```bash
# Remove old versions
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Install prerequisites
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group (avoids needing sudo)
sudo usermod -aG docker $USER

# IMPORTANT: Log out and back in for group changes to take effect
# Or run: newgrp docker

# Verify
docker --version
docker compose version
```

## 9. Verify All Installations

```bash
echo "=== Verification ==="
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "terminalizer: $(terminalizer --version)"
echo "gh: $(gh --version | head -1)"
echo "java: $(java --version | head -1)"
echo "jenv: $(jenv --version)"
echo "docker: $(docker --version)"
echo "docker compose: $(docker compose version)"
echo "make: $(make --version | head -1)"
echo "git: $(git --version)"
```

---

## Recording the Demo

### 1. Configure Terminalizer (optional)

```bash
# Generate default config
terminalizer config

# Edit config if needed
nano ~/.terminalizer/config.yml
```

### 2. Start Recording

```bash
cd /tmp
terminalizer record promsnmp-demo
```

### 3. Commands to Type

```bash
gh repo clone pbrane/promsnmp-metrics
cd promsnmp-metrics
jenv local 21
make
cd deployment
docker compose up -d
sleep 15
curl -s http://localhost:8080/promsnmp/hello
```

Press `Ctrl+D` to stop recording.

### 4. Preview (optional)

```bash
terminalizer play promsnmp-demo
```

### 5. Render to GIF

```bash
terminalizer render promsnmp-demo -o promsnmp-demo.gif
```

### 6. Adjust Speed (optional)

Upload to https://ezgif.com/speed to speed up if needed.

---

## Cleanup After Recording

```bash
cd /tmp/promsnmp-metrics/deployment
docker compose down
cd /tmp
rm -rf promsnmp-metrics
```

---

## Troubleshooting

### Docker permission denied
```bash
# Log out and back in, or:
newgrp docker
```

### jenv not finding Java
```bash
# Find Java path
ls -la /usr/lib/jvm/
# Add it manually (use your architecture)
# ARM64: jenv add /usr/lib/jvm/java-21-openjdk-arm64
# AMD64: jenv add /usr/lib/jvm/java-21-openjdk-amd64
```

### Terminalizer render fails
```bash
# May need additional dependencies
sudo apt install -y libfontconfig1
```

### gh auth issues
```bash
gh auth login
# Choose: GitHub.com → HTTPS → Yes → Login with browser
```
