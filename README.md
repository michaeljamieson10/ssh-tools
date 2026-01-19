# SSH Tools

Easy SSH connection utilities for accessing remote servers and managing Arduino projects.

## Project Overview

This repository provides SSH connection tools for working with an **Ubuntu 24.04 LTS server running on a Mac Mini 2014**. The server is set up for Arduino development, specifically for programming and interfacing with an **Arduino Uno** via USB. The primary connection is now via **Tailscale**.

### Use Case

The Mac Mini 2014 runs Ubuntu Server as a headless development environment for Arduino projects. This allows:
- Remote Arduino sketch compilation and uploading
- Server-side Arduino automation and monitoring
- Centralized Arduino project management
- Running Arduino projects 24/7 without tying up a desktop computer

## What This Does

This repository contains a helper script that makes it easy to:
- Connect to your Ubuntu server (Mac Mini 2014) via SSH
- Run commands remotely for Arduino development
- Copy Arduino sketches to/from the server
- Automatically handle authentication
- Manage Arduino Uno connected via USB

## Setup

### Prerequisites

The script will automatically install `sshpass` if needed, but you can install it manually:

**macOS:**
```bash
brew install hudochenkov/sshpass/sshpass
```

**Linux:**
```bash
sudo apt-get install sshpass
```

### Configuration

Edit the variables at the top of `connect-server.sh` to match your server, or override them with environment variables (recommended):

```bash
SERVER_USER="jamieson"
SERVER_IP="100.88.255.106"
SERVER_PASSWORD="password"
```

Environment override example:

```bash
SERVER_USER=jamieson SERVER_IP=100.88.255.106 SERVER_PASSWORD=password ./connect-server.sh connect
```

## Usage

### Connect to Server

Just run the script to open an interactive SSH session:

```bash
./connect-server.sh
# or
./connect-server.sh connect
```

### Run Remote Commands

Execute a single command on the server:

```bash
./connect-server.sh run 'ls -la'
./connect-server.sh run 'arduino-cli board list'
./connect-server.sh run 'sudo systemctl status nginx'
```

### Copy Files to Server

```bash
./connect-server.sh copy ./local-file.txt /home/jamieson/
./connect-server.sh copy ./my-sketch /home/jamieson/arduino_projects/
```

### Copy Files from Server

```bash
./connect-server.sh fetch /home/jamieson/data.txt ./
./connect-server.sh fetch /var/log/syslog ./server-logs/
```

## How It Works

The script uses `sshpass` to automate SSH password authentication. Here's what happens:

1. **Installation Check**: The script first checks if `sshpass` is installed
2. **Auto-Install**: If not found, it automatically installs it based on your OS
3. **Connection**: Uses `sshpass -p 'password' ssh user@host` to connect
4. **Security Options**: `-o StrictHostKeyChecking=no` skips host key verification (useful for local networks)

### Technical Details

- **SSH Connection**: `sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@$IP`
- **Remote Command**: Same as above but with command string appended
- **SCP Transfer**: `sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no source dest`

## Server Information

**Hardware:**
- **Device**: Mac Mini 2014
- **Purpose**: Headless Ubuntu server for Arduino development
- **Connection**: Tailscale at 100.88.255.106

**Software:**
- **User**: jamieson
- **IP (Tailscale)**: 100.88.255.106
- **Password**: password
- **OS**: Ubuntu 24.04.3 LTS (Noble)
- **Kernel**: Linux 6.8.0-90-generic
- **Arduino CLI**: Installed at `~/bin/arduino-cli` (available in `connect-server.sh run`)
- **Architecture**: x86_64 (64-bit)

**Arduino Hardware:**
- **Board**: Arduino Uno
- **Connection**: USB-B to USB-A cable (typically appears as `/dev/ttyACM0` or `/dev/ttyUSB0`)
- **Supported**: Full compile, upload, and serial monitor capabilities

## Arduino Development Workflow

The server has Arduino CLI installed for working with Arduino Uno. This enables a complete development workflow:

```bash
# Check connected boards
./connect-server.sh run 'arduino-cli board list'

# Compile a sketch
./connect-server.sh run 'arduino-cli compile --fqbn arduino:avr:uno ~/arduino_projects/blink_test'

# Upload to Arduino
./connect-server.sh run 'arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno ~/arduino_projects/blink_test'

# Monitor serial output
./connect-server.sh run 'arduino-cli monitor -p /dev/ttyACM0'
```

## Examples

### Upload and Run an Arduino Sketch

```bash
# Copy your sketch to the server
./connect-server.sh copy ./my_sketch /home/jamieson/arduino_projects/

# Compile it
./connect-server.sh run 'arduino-cli compile --fqbn arduino:avr:uno ~/arduino_projects/my_sketch'

# Upload to connected Arduino Uno
./connect-server.sh run 'arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno ~/arduino_projects/my_sketch'
```

### Check Server Status

```bash
./connect-server.sh run 'uptime'
./connect-server.sh run 'df -h'
./connect-server.sh run 'free -h'
```

### File Management

```bash
# List files
./connect-server.sh run 'ls -lah ~'

# Create directory
./connect-server.sh run 'mkdir -p ~/my-project'

# Check file contents
./connect-server.sh run 'cat ~/arduino_projects/blink_test/blink_test.ino'
```

## Security Note

**Warning**: This script stores passwords in plain text. This is acceptable for:
- Local network servers
- Development/testing environments
- Personal projects on trusted networks

**For production use**, consider:
- Using SSH key-based authentication (more secure)
- Storing credentials in environment variables
- Using a password manager or secrets vault

### Setting Up SSH Keys (Recommended)

For better security, set up SSH keys:

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519

# Copy public key to server
ssh-copy-id jamieson@100.88.255.106

# Now you can connect without password
ssh jamieson@100.88.255.106
```

## Troubleshooting

### Permission Denied
- Check username and password are correct
- Verify server IP address is reachable: `ping 100.88.255.106`

### sshpass Not Found
- Run the script once, it will auto-install
- Or manually install: `brew install hudochenkov/sshpass/sshpass`

### Arduino Upload Fails
- Check if Arduino is connected: `./connect-server.sh run 'arduino-cli board list'`
- Verify user is in dialout group: `./connect-server.sh run 'groups'`
- If dialout not in groups, log out and back in to the server

## Tailscale + Arduino CLI Notes

These are the commands used most often on the Tailscale-hosted server:

```bash
# Detect the Arduino over USB
./connect-server.sh run 'lsusb'

# Check the serial device
./connect-server.sh run 'ls -l /dev/ttyACM* /dev/ttyUSB*'

# Detect board via Arduino CLI
./connect-server.sh run 'arduino-cli board list'

# Compile and upload a sketch
./connect-server.sh run 'arduino-cli compile --fqbn arduino:avr:uno ~/arduino_projects/arduino-lab/blink_5x'
./connect-server.sh run 'arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno ~/arduino_projects/arduino-lab/blink_5x'
```

## License

MIT License - Feel free to use and modify as needed.
