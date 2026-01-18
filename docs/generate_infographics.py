#!/usr/bin/env python3
"""
Generate professional infographics for PromSNMP deployment scenarios.
Uses VibeGraphics/Gemini for image generation.
"""

import sys
import os

# Add VibeGraphics to path
sys.path.insert(0, '/Users/mhuot/VibeGraphics/servers')

from vibegraphics_mcp import banana_generate

OUTPUT_DIR = "/Users/mhuot/promsnmp-gemini/docs/images"

# Professional clean theme specifications
THEME = """
Style: Clean, modern, professional infographic
Color palette: Deep navy blue (#1a365d), teal accent (#0d9488), white backgrounds, subtle gray (#f1f5f9) containers
Typography: Sans-serif, clean hierarchy, minimal text
Layout: Organized, symmetrical, clear visual flow with connecting lines
Icons: Simple, flat, monochrome technical icons
Mood: Enterprise-grade, trustworthy, technical but accessible
No: Gradients, shadows, 3D effects, busy backgrounds, cartoon elements
"""

INFOGRAPHICS = [
    {
        "name": "docker-deployment",
        "prompt": f"""
Create a professional technical infographic showing Docker Compose deployment architecture:

LAYOUT (left to right flow):
- Left side: "Prometheus" server icon connecting to center
- Center: "HAProxy Load Balancer" box at top
- Below HAProxy: Three container boxes labeled "PromSNMP 1 (Leader)", "PromSNMP 2", "PromSNMP 3"
- All three containers connect down to a "Shared Volume" cylinder (inventory.json)
- Right side: "SNMP Network Devices" (router, switch icons)
- Arrows showing data flow

KEY ELEMENTS:
- Leader container highlighted with green accent
- Follower containers in blue
- Health check indicators (green dots)
- Port labels: 8080, 8404

{THEME}

Title at top: "PromSNMP Docker Compose Deployment"
Subtitle: "Fault-tolerant SNMP monitoring with HAProxy load balancing"
"""
    },
    {
        "name": "kubernetes-deployment",
        "prompt": f"""
Create a professional technical infographic showing Kubernetes deployment architecture:

LAYOUT (hierarchical, top to bottom):
- Top: "Ingress Controller" bar
- Below: "Service (ClusterIP)" box
- Middle: Kubernetes namespace box containing:
  - "Deployment" with 3 pod icons inside (Pod 1 Leader in green, Pod 2, Pod 3 in blue)
  - "Redis StatefulSet" for leader election (small, to the side)
  - "PVC" storage cylinder connected to all pods
- Bottom: "StorageClass (NFS/EFS)"
- Right side: "Network Devices" with SNMP connection arrows

KEY ELEMENTS:
- Kubernetes logo styling
- Pod anti-affinity indicator
- HPA scaling arrows
- PodDisruptionBudget notation (min 2 available)
- ConfigMap and Secret icons

{THEME}

Title at top: "PromSNMP Kubernetes Deployment"
Subtitle: "Auto-scaling SNMP exporter with leader election"
"""
    },
    {
        "name": "cloud-manager-deployment",
        "prompt": f"""
Create a professional technical infographic showing Cloud Manager fleet architecture:

LAYOUT (hub and spoke):
- Center: Large "Cloud Manager" box containing:
  - REST API icon
  - WebSocket icon
  - Database cylinder (PostgreSQL)
  - "Leader Election" component

- Radiating outward: Three site boxes at different positions:
  - "Site A - Chicago" with 3 small PromSNMP container icons
  - "Site B - New York" with 2 small PromSNMP container icons
  - "Site C - London" with 2 small PromSNMP container icons

- Each site has small "SNMP Devices" icons below it
- Bidirectional arrows from each site to Cloud Manager (labeled HTTPS/WSS)
- One container in each site highlighted green (Leader)

KEY ELEMENTS:
- Global/cloud iconography for central manager
- Geographic/location indicators for sites
- Real-time sync indicators
- Fleet dashboard preview

{THEME}

Title at top: "PromSNMP Cloud Manager Architecture"
Subtitle: "Centralized fleet management across multiple sites"
"""
    }
]


def generate_infographic(name: str, prompt: str) -> str:
    """Generate a single infographic."""
    print(f"\n{'='*60}")
    print(f"Generating: {name}")
    print(f"{'='*60}")

    result = banana_generate(
        prompt=prompt,
        out_dir=OUTPUT_DIR,
        model="gemini-3-pro-image-preview",  # Nano Banana Pro (latest)
        n=1
    )

    print(f"Result: {result}")
    return result


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    results = {}
    for info in INFOGRAPHICS:
        try:
            result = generate_infographic(info["name"], info["prompt"])
            results[info["name"]] = result
        except Exception as e:
            print(f"Error generating {info['name']}: {e}")
            results[info["name"]] = f"ERROR: {e}"

    print("\n" + "="*60)
    print("GENERATION COMPLETE")
    print("="*60)
    for name, result in results.items():
        print(f"  {name}: {result}")


if __name__ == "__main__":
    main()
