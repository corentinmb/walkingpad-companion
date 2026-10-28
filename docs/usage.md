# Using Walkingpad Companion

Allow Bluetooth access when first launching the app. Turn on a compatible WalkingPad and wait for its connection. Start/Stop and speed commands affect the physical treadmill. Speed controls are available while running in manual mode; automatic mode leaves speed control to the treadmill.

The app requests Bluetooth status every 500 ms and updates the live counters as
responses arrive. The treadmill's internal refresh and Bluetooth response time still
limit how quickly a physical step appears on screen.

## Live Bluetooth steps in the terminal

Quit any running copy of Walkingpad Companion, then run from the repository:

```sh
bash scripts/build-app.sh debug
bash scripts/stream-steps.sh
```

Allow Bluetooth access if macOS asks. The script runs the app in the foreground;
Ctrl+C stops it. It only requests status, without starting the belt or changing speed.

Each received status packet produces an immediately flushed line, including unchanged
step counts:

```text
[Bluetooth] 2026-10-28T10:30:00.123Z type=current steps=9722 distance_m=3000 time_s=5415 speed_kmh=2.0 raw_steps=00 25 FA
```

`steps` is the treadmill's session counter, before the app's daily accumulation.
`raw_steps` contains its three Bluetooth bytes in hexadecimal. `type=last` identifies
a historical status packet rather than a current reading. Timestamps mark reception
on the Mac, in UTC, rather than the time of the physical footfall.

Like the app's normal mode, this mode requests status every 500 ms. It adds no
output buffering, but the treadmill's internal counter refresh and Bluetooth response
time still limit latency. No output appears until the treadmill sends a status packet.

## Statistics

### Personal P1 step calibration

The main step counter, menu bar and daily goal use estimated steps. The panel also
shows the unchanged **P1 raw** daily counter for comparison. Personal measurements
give a factor of 90/165 at 2 km/h, approximately 90/110 at 2.5 km/h and 120/100
at 3 km/h. Factors are linearly interpolated between adjacent measured speeds;
outside 2–3 km/h raw steps are used. This is a personal estimate, especially at
2.5 and 3 km/h where the measurements were approximate.

Each new step increment is calibrated using the previously reported speed. Changing
speed never recalculates earlier increments. Fractional steps are retained before
rounding for display, and both totals are saved. Earlier saved steps and initial
session counters without a known speed history stay unchanged, so an existing day's
estimate may include uncalibrated steps. The HTTP API and built-in statistics window use the
estimated step total, matching Companion. Distance, Bluetooth logs, MQTT and fitness
uploads retain their original values; KS Fit and the P1 are not modified.

The Stats button opens a native **Walkingpad Companion** window with today's
estimated steps, walking time and distance, total steps, best day and saved workout
history. It observes the same live workout as the menu, so updates arrive directly
from Companion. It works offline without loading an external website or using a
browser, HTTP connection or WebSocket.

For optional integrations, the app still exposes a local HTTP API on IPv4 loopback:

- `http://127.0.0.1:4934/treadmill`: current treadmill state and accumulated statistics.
- `http://127.0.0.1:4934/treadmill/workouts`: workout history.

These endpoints return JSON, not an HTML dashboard. Keep the app running to use
them. This API is unauthenticated and should not be exposed publicly.

## Fitness synchronization

The Login button connects to HCGateway. Install and configure [HCGateway](https://github.com/ShuchirJ/HCGateway) on your phone, then use the same credentials in the app. This integration is optional and sends workout data to the hosted HCGateway service at `https://api.hcgateway.shuchir.dev`. See the login window for its setup link.

## MQTT configuration

You can publish the current WalkingPad state as MQTT message. An example use case is to use the current state
for automations in your favorite home automation tool like Home Assistant.

To configure the app to use MQTT, you need to provide a config file containing the connection data. Please
place this file in `~/Library/Containers/klassm.walkingpad-client/Data/Library/Autosave Information/.walkingpad-client-mqtt.json`
(this is quite a complex path, however it does not require any additional permissions to read it).

```json
{
  "username": "myusername",
  "password": "mypassword",
  "host": "192.168.0.73",
  "port": 1883,
  "topic": "homeassistant/sensor/walkingpad"
}
```

The app will automatically read the config data and start to publish messages.

An example message looks like the following:
```
{
    "speedKmh":1.5,
    "stepsTotal":19202,
    "distanceTotal":4690,
    "stepsWalkingpad":510
}
```

Home Assistant can afterwards be configured to read the data.

```yaml
mqtt:
  sensor:
    - name: "WalkingPad Speed"
      object_id: "walkingpad_speed"
      state_topic: "homeassistant/sensor/walkingpad"
      value_template: "{{ value_json.speedKmh }}"
      unit_of_measurement: "km/h"
    - name: "WalkingPad Steps"
      object_id: "walkingpad_steps"
      state_topic: "homeassistant/sensor/walkingpad"
      value_template: "{{ value_json.stepsTotal }}"
      unit_of_measurement: "Steps"
```
