# Cortex

Intended to run on a device connected to microcontrollers via serial port.

Firmata code for each microcontroller is maintained in the cortex.

This allows for code changes as requested by external systems.

Cortex ensures that each microcontroller is identified and code loaded.

**Identification** of each MCU occurs based on the firmware name reported by Firmata

Each connected MCU have a unique firmware name. Set it by changing the sketch filename.

## Features

* Web interface for device configuration
* Enumerate, persist, and autoload code for each devices
* Remotely alter code for each device

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
