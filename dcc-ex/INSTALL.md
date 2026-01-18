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

### Your Setup
- **Arduino Uno** ✓
- **L298N Motor Shield** ✓ (WWZMDiB 2 Pcs L298N Motor Driver Controller Board)
  - Dual H-Bridge module
  - Supports up to 2A per channel
  - Works perfectly with DCC-EX

### L298N Shield Wiring
The L298N module connects to Arduino via jumper wires:
- **ENA** → Arduino Pin 3 (PWM)
- **IN1** → Arduino Pin 4
- **IN2** → Arduino Pin 5
- **IN3** → Arduino Pin 6
- **IN4** → Arduino Pin 7
- **ENB** → Arduino Pin 9 (PWM)
- **GND** → Arduino GND
- **5V** → Arduino 5V (for logic) OR external power supply

**Track Power**: Connect external 7-12V DC power supply to L298N's power input.

### Optional Hardware
- **WiFi Shield** or **ESP8266/ESP32** for wireless throttle control
- **Higher current motor driver** (if running many trains)

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

### Step 3: Configure for Your L298N Setup

The main configuration file is `config.h`. You'll need to edit it for your L298N motor shield:

```bash
./connect-server.sh run 'nano ~/arduino_projects/CommandStation-EX/config.h'
```

**Key Configuration for L298N:**

1. **Motor Shield Selection** - For your L298N shield, you need a custom configuration:

   Look for the motor shield type section and add/uncomment:
   ```cpp
   #define MOTOR_SHIELD_TYPE L298N_MOTOR_SHIELD
   ```

   **OR** if L298N_MOTOR_SHIELD is not available in your version, use custom pin config:
   ```cpp
   #define MOTOR_SHIELD_TYPE STANDARD_MOTOR_SHIELD
   ```

   Then create a custom pin configuration in `MotorDrivers.h` or use the standard pins with jumper wiring as shown above.

2. **For L298N Standalone Module** - The easiest approach is to define custom pins:
   ```cpp
   // Main track (Channel A)
   #define MAIN_ENABLE_PIN 3
   #define MAIN_SIGNAL_PIN 4
   #define MAIN_SIGNAL_PIN_ALT 5
   #define MAIN_SENSE_PIN A0

   // Programming track (Channel B)
   #define PROG_ENABLE_PIN 9
   #define PROG_SIGNAL_PIN 6
   #define PROG_SIGNAL_PIN_ALT 7
   #define PROG_SENSE_PIN A1
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
