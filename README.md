# Setup
- Clone/Download the main SACC application from this repository and the [bridge application](https://github.com/LuPro/OPC-UA-bridge).
    - If you have not created any PnIDs yourself, you can download sample PnIDs for Festo's MPS403 industry facility demonstrator [here](https://github.com/LuPro/MPS400-PnID)
- Your PnID Location needs to contain a symlink or copy of the "ui" folder on the same level as the base PnID QML files (and so does the main executable).


# Basic Usage
- Run SACC.
- Select "Primary", optionally define custom ports for Backend and Forward connections, then click "Start". On Windows this may need Administrator access to allow connections through the firewall.
    - If you're instead connecting to another SACC instance as a secondary GUI, switch to "Secondary" and enter that instance's IP address and port.
- Run your bridge application to connect the hardware to SACC. See its help text for info on usage.
    - If you restart the OPC UA Servers (eg: by restarting the PLCs) or close the SACC GUI, you need to close and restart the OPC UA Bridges (auto-reconnect not yet implemented)
