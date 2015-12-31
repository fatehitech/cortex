# Cortex

Maintains **Things** which contain behavior code, time-series code, actions, and that sort of thing.

One or more [Axon](https://github.com/fatehitech/axon) nodes connect to Cortex.

The idea here is to keep the software of the end nodes very generic (e.g. Firmata, Axon) and make the real logic come from the web editor in Cortex.

## Usage

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
