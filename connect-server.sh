#!/bin/bash

# SSH Connection Helper Script
# Easy connection to your Ubuntu server

SERVER_USER="jamieson"
SERVER_IP="172.16.0.11"
SERVER_PASSWORD="password"

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install hudochenkov/sshpass/sshpass
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo apt-get update && sudo apt-get install -y sshpass
    else
        echo "Unsupported OS. Please install sshpass manually."
        exit 1
    fi
fi

# Function to connect to server
connect() {
    echo "Connecting to $SERVER_USER@$SERVER_IP..."
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP"
}

# Function to run a command on the server
run_command() {
    if [ -z "$1" ]; then
        echo "Usage: $0 run '<command>'"
        exit 1
    fi
    echo "Running command on server: $1"
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" "$1"
}

# Function to copy files to server
copy_to_server() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 copy <local_path> <remote_path>"
        exit 1
    fi
    echo "Copying $1 to $SERVER_USER@$SERVER_IP:$2"
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$1" "$SERVER_USER@$SERVER_IP:$2"
}

# Function to copy files from server
copy_from_server() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 fetch <remote_path> <local_path>"
        exit 1
    fi
    echo "Copying $SERVER_USER@$SERVER_IP:$1 to $2"
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP:$1" "$2"
}

# Main script logic
case "${1:-connect}" in
    connect)
        connect
        ;;
    run)
        run_command "$2"
        ;;
    copy)
        copy_to_server "$2" "$3"
        ;;
    fetch)
        copy_from_server "$2" "$3"
        ;;
    *)
        echo "SSH Connection Helper"
        echo ""
        echo "Usage:"
        echo "  $0 [command] [arguments]"
        echo ""
        echo "Commands:"
        echo "  connect              - Connect to the server (default)"
        echo "  run '<command>'      - Run a command on the server"
        echo "  copy <local> <remote> - Copy file to server"
        echo "  fetch <remote> <local> - Copy file from server"
        echo ""
        echo "Examples:"
        echo "  $0                                    # Connect to server"
        echo "  $0 connect                            # Connect to server"
        echo "  $0 run 'ls -la'                       # Run ls command"
        echo "  $0 copy ./file.txt /home/jamieson/    # Copy to server"
        echo "  $0 fetch /home/jamieson/data.txt ./   # Copy from server"
        exit 1
        ;;
esac
