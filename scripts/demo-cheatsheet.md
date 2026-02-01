# PromSNMP Demo Recording Cheat Sheet

Follow these steps while recording with asciinema.

## Prerequisites

```bash
# Install tools
brew install asciinema agg

# Ensure clean state (no existing clone in working dir)
cd ~/tmp  # or wherever you want to record from
rm -rf promsnmp-metrics  # if exists
```

## Start Recording

```bash
asciinema rec promsnmp-demo.cast
```

---

## Commands to Type (in order)

### 1. Clone the repo
```
gh repo clone pbrane/promsnmp-metrics
```
*Wait for clone to complete*

### 2. Enter directory
```
cd promsnmp-metrics
```

### 3. Set Java version
```
jenv local 21
```

### 4. Build the project
```
make
```
*Wait for build to complete (~30-60 sec)*

### 5. Go to deployment
```
cd deployment
```

### 6. Start the stack
```
docker compose up -d
```
*Wait for containers to start*

### 7. Wait for services
```
sleep 15
```

### 8. Test hello endpoint
```
curl -s http://localhost:8080/promsnmp/hello
```

### 9. Show sample metrics (optional)
```
curl -s http://localhost:8080/metrics | head -20
```

### 10. Exit recording
Press `Ctrl+D` or type `exit`

---

## Post-Recording

```bash
# Convert to GIF
agg promsnmp-demo.cast promsnmp-demo.gif \
    --theme dracula \
    --font-size 14 \
    --cols 100 \
    --rows 30

# Preview
open promsnmp-demo.gif

# Optional: Speed up at https://ezgif.com/speed
# Upload, set speed to 150-200%, download

# Move to docs
mv promsnmp-demo.gif ~/promsnmp-gemini/docs/images/
```

## Cleanup After Recording

```bash
cd ~/tmp/promsnmp-metrics/deployment
docker compose down
cd ~/tmp
rm -rf promsnmp-metrics
```

---

## Tips

- **Pause before typing**: Give viewers time to read output
- **Type steadily**: Not too fast, not too slow
- **Clear typos**: If you make a mistake, Ctrl+C and retype
- **Keep it short**: Aim for < 60 seconds final GIF
