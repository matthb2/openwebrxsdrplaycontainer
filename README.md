### Host Setup
You'll need to install the SDRPlay udev rules so that your device shows up as the driver expects:

```
cp 66-mirics.rules /etc/udev/rules.d/
udevadm control --reload-rules && udevadm trigger 
```

### Build and Run

```
podman build -t sdrp ./
podman run --net=host -v/dev:/dev -dt sdrp:latest
```

