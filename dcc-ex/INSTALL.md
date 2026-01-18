# DCC-EX CommandStation Installation Guide

This guide explains how to install DCC-EX CommandStation-EX v5.4.15 on your Arduino Uno connected to the Ubuntu server.

## What is DCC-EX?

DCC-EX CommandStation turns your Arduino into a complete DCC (Digital Command Control) command station for model trains. This allows you to:
- Control DCC-equipped locomotives
- Operate turnouts/points
- Run multiple trains simultaneously
- Use WiFi throttles (with additional hardware)
- Automate train operations

## Hardware Requirements

### Minimum Setup (Arduino Uno)
- **Arduino Uno** (what you have)
- **Motor Shield** (required for track power):
  - Arduino Motor Shield R3 (recommended)
  - Deek-Robot Motor Shield
  - Other compatible L298N-based shields

### Optional Hardware
- **WiFi Shield** or **ESP8266/ESP32** for wireless throttle control
- **Motor Driver** (for higher current requirements)

**Important**: The Arduino Uno alone cannot power the tracks. You MUST have a motor shield to provide power to your model trains.

## Installation Steps

### Step 1: Transfer DCC-EX to Server

When the server is accessible, run:

```bash
cd /Users/michaeljamieson/Code/ssh-tools
./connect-server.sh copy ./dcc-ex/CommandStation-EX.tar.gz /home/jamieson/
```

### Step 2: Extract on Server

```bash
./connect-server.sh run 'cd ~ && tar -xzf CommandStation-EX.tar.gz && mv CommandStation-EX arduino_projects/'
```

### Step 3: Configure for Your Setup

The main configuration file is `config.h`. You'll need to edit it for your motor shield:

```bash
./connect-server.sh run 'nano ~/arduino_projects/CommandStation-EX/config.h'
```

**Key Configuration Options:**

1. **Motor Shield Selection** - Uncomment ONE of these lines based on your hardware:
   ```cpp
   #define MOTOR_SHIELD_TYPE STANDARD_MOTOR_SHIELD  // Arduino Motor Shield R3
   // #define MOTOR_SHIELD_TYPE POLOLU_MOTOR_SHIELD
   // #define MOTOR_SHIELD_TYPE FUNDUMOTO_SHIELD
   // #define MOTOR_SHIELD_TYPE FIREBOX_MK1
   // #define MOTOR_SHIELD_TYPE IBT_2_WITH_ARDUINO
   ```

2. **WiFi Configuration** (optional, if you have WiFi shield):
   ```cpp
   #define WIFI_SSID "your-network-name"
   #define WIFI_PASSWORD "your-password"
   ```

3. **Enable Features**:
   ```cpp
   #define ENABLE_WIFI          // If you have WiFi capability
   #define ENABLE_ETHERNET      // If you have Ethernet shield
   ```

### Step 4: Compile and Upload

Once configured, compile and upload to your Arduino Uno:

```bash
# Navigate to the project
./connect-server.sh run 'cd ~/arduino_projects/CommandStation-EX'

# Compile the sketch
./connect-server.sh run 'arduino-cli compile --fqbn arduino:avr:uno ~/arduino_projects/CommandStation-EX'

# Upload to Arduino (make sure it's plugged in!)
./connect-server.sh run 'arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno ~/arduino_projects/CommandStation-EX'
```

### Step 5: Test the Command Station

Monitor the serial output to verify it's working:

```bash
./connect-server.sh run 'arduino-cli monitor -p /dev/ttyACM0 -b 115200'
```

You should see output like:
```
<iDCC-EX V-5.4.15 / MEGA / STANDARD_MOTOR_SHIELD G-9b61278>
<N1: Serial>
<* READY *>
```

## Using DCC-EX

### Serial Commands

You can send DCC commands via serial. Common commands:

```bash
# Read loco on programming track
./connect-server.sh run 'echo "<R>" | arduino-cli monitor -p /dev/ttyACM0 -b 115200'

# Set track power ON
./connect-server.sh run 'echo "<1>" | arduino-cli monitor -p /dev/ttyACM0 -b 115200'

# Set track power OFF
./connect-server.sh run 'echo "<0>" | arduino-cli monitor -p /dev/ttyACM0 -b 115200'

# Run loco 3 forward at speed 50
./connect-server.sh run 'echo "<t 1 3 50 1>" | arduino-cli monitor -p /dev/ttyACM0 -b 115200'
```

### DCC-EX Command Reference

- `<1>` - Power ON
- `<0>` - Power OFF
- `<t CAB ADDR SPEED DIR>` - Throttle control
  - CAB: Register (1-10)
  - ADDR: Loco address (1-127 short, 128-10239 long)
  - SPEED: 0-126 (-1 for emergency stop)
  - DIR: 1=forward, 0=reverse
- `<T TURNOUT_ID ADDR SUBADDR STATE>` - Turnout control
- `<R>` - Read CV values on programming track
- `<W CV VALUE>` - Write CV values

### Using Throttle Apps

If you add WiFi capability, you can control trains with apps:

**Compatible Apps:**
- **Engine Driver** (Android) - Free, popular
- **WiThrottle** (iOS) - Official app
- **Cab Engineer** (iOS/Android)
- **JMRI** (Computer) - Full featured

The Arduino will broadcast as a WiThrottle server that these apps can connect to.

## Troubleshooting

### No Serial Output
- Check baud rate is set to 115200
- Verify Arduino is connected: `./connect-server.sh run 'arduino-cli board list'`

### Upload Fails
- Make sure user is in dialout group
- Try unplugging and re-plugging the Arduino
- Check correct port: might be `/dev/ttyUSB0` instead of `/dev/ttyACM0`

### Motor Shield Not Detected
- Verify motor shield is properly seated on Arduino
- Check config.h has correct shield type uncommented
- Some shields need jumper configuration

### No Track Power
- Verify motor shield is connected
- Check power supply to motor shield
- Use `<1>` command to enable power
- Check motor shield current limits

## Next Steps

1. **Get a Motor Shield**: Order an Arduino Motor Shield R3 or compatible
2. **Test with LEDs**: Before connecting to trains, test with LEDs on outputs
3. **Read DCC-EX Docs**: https://dcc-ex.com
4. **Join Community**: DCC-EX Discord for support

## Additional Resources

- **Official Docs**: https://dcc-ex.com/ex-commandstation/index.html
- **Command Reference**: https://dcc-ex.com/reference/software/command-reference.html
- **GitHub**: https://github.com/DCC-EX/CommandStation-EX
- **YouTube Tutorials**: Search "DCC-EX setup"

## Version Information

- **DCC-EX Version**: v5.4.15-Prod (Latest stable as of Aug 2024)
- **Arduino Board**: Arduino Uno
- **Compilation**: Arduino CLI
- **Server**: Ubuntu 24.04 on Mac Mini 2014
