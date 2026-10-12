# Using Walkingpad Companion

Allow Bluetooth access when first launching the app. Turn on a compatible WalkingPad and wait for its connection. Start/Stop and speed commands affect the physical treadmill. Speed controls are available while running in manual mode; automatic mode leaves speed control to the treadmill.

## Statistics

The Stats button opens https://walkingpad-stats.netlify.app/. This is an external statistics viewer, separate from this repository’s presentation website. The app exposes data through its local server on port 4934:

- `http://localhost:4934/treadmill`: current treadmill state and accumulated statistics.
- `http://localhost:4934/treadmill/workouts`: workout history.

The endpoints return JSON, not an HTML dashboard. Keep the app running to use them. The local server uses the existing Embassy configuration; it is not an authenticated API and should not be exposed publicly.

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
