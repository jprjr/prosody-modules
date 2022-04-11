# Introduction

This module adds a room configuration option to allow discovering room
occupants via Service Discovery.

# Configuring

## Enabling

``` {.lua}
Component "rooms.example.net" "muc"
modules_enabled = {
	"muc_disco_occupants";
}
```

## Settings

A default setting can be provided in the config file:

``` {.lua}
muc_room_default_discover_occupants = true ; -- default is false
```
