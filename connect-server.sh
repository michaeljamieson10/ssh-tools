#!/bin/bash

# SSH Connection Helper Script
# Easy connection to your Ubuntu server

SERVER_USER_DEFAULT="jamieson"
SERVER_IP_DEFAULT="100.88.255.106"
SERVER_PASSWORD_DEFAULT="password"

if [ -z "${SERVER_USER+x}" ]; then
    SERVER_USER="$SERVER_USER_DEFAULT"
fi
if [ -z "${SERVER_IP+x}" ]; then
    SERVER_IP="$SERVER_IP_DEFAULT"
fi
if [ -z "${SERVER_PASSWORD+x}" ]; then
    SERVER_PASSWORD="$SERVER_PASSWORD_DEFAULT"
fi

USE_SSHPASS=0
if [ -n "$SERVER_PASSWORD" ]; then
    USE_SSHPASS=1
fi

if [ "$USE_SSHPASS" -eq 1 ]; then
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
fi

SSH_OPTS=(-o StrictHostKeyChecking=no)
if [ "$USE_SSHPASS" -eq 0 ]; then
    SSH_OPTS+=(-o BatchMode=yes)
fi

run_ssh() {
    if [ "$USE_SSHPASS" -eq 1 ]; then
        sshpass -p "$SERVER_PASSWORD" ssh "${SSH_OPTS[@]}" "$SERVER_USER@$SERVER_IP" "$@"
    else
        ssh "${SSH_OPTS[@]}" "$SERVER_USER@$SERVER_IP" "$@"
    fi
}

run_scp() {
    if [ "$USE_SSHPASS" -eq 1 ]; then
        sshpass -p "$SERVER_PASSWORD" scp "${SSH_OPTS[@]}" "$@"
    else
        scp "${SSH_OPTS[@]}" "$@"
    fi
}

# Function to connect to server
connect() {
    echo "Connecting to $SERVER_USER@$SERVER_IP..."
    run_ssh
}

# Function to run a command on the server
run_command() {
    if [ -z "$1" ]; then
        echo "Usage: $0 run '<command>'"
        exit 1
    fi
    echo "Running command on server: $1"
    run_ssh "PATH=\"\$HOME/bin:\$PATH\"; $1"
}

# Function to copy files to server
copy_to_server() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 copy <local_path> <remote_path>"
        exit 1
    fi
    echo "Copying $1 to $SERVER_USER@$SERVER_IP:$2"
    run_scp "$1" "$SERVER_USER@$SERVER_IP:$2"
}

# Function to copy files from server
copy_from_server() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 fetch <remote_path> <local_path>"
        exit 1
    fi
    echo "Copying $SERVER_USER@$SERVER_IP:$1 to $2"
    run_scp "$SERVER_USER@$SERVER_IP:$1" "$2"
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
