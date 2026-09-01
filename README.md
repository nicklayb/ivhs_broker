# IVHS Broker

Configuration broker for [IVHS card system](https://github.com/nicklayb/ivhs). This application is used as a middleware between the player (an MQTT broker, for now) and the card reader. This is where cards are configured.

**Note**: It doesn't (at least for the moment) include an internal MQTT broker, so you will need to have yours setup. This application is (at least for the moment) expected to be used with Home Assistant so there are a lot of chances you already have an MQTT broker.

![Screenshot of the log page](screenshot.png)

## Installation

Example `docker-compose.yml`:

```yaml
services:
  ivhs:
    image: nboisvert/ivhs:latest
    ports:
      - 4000:4000
    depends_on:
      - postgres

    environment:
      # Phoenix configuration
      - SECRET_KEY_BASE= # 32 bit random string
      - LIVE_VIEW_SALT= # 16 bit random string
      - APP_HOST= # Sets the app host if the app is hosted behind a reverse proxy (Expects FQDN like https://ivhs.katchow.com)

      # Database configuration
      - DATABASE_PATH= # Database path similar to postgresql://postgres:postgres@localhost/ivhs_broker 

      # MQTT Configuration
      - MQTT_HOST= # MQTT Host
      - MQTT_PORT= # MQTT Port (optional, defaults to 1883)
      - MQTT_CLIENT_ID= # MQTT Client (optional, defaults to "ivhs")
      - MQTT_USERNAME= # MQTT Username (optional, default to empty string)
      - MQTT_PASSWORD= # MQTT Password (optional, default to empty string)
      - MQTT_HOST= # MQTT Host

      # Plex configuration
      - PLEX_HOST= # Host of the plex instance
      - PLEX_TOKEN= # Token to authenticate with (optional if Plex is locally accessible) 

      # Various configuration
      - LOGGER_LEVEL= # Logger level to apply (See available levels at: https://www.erlang.org/doc/apps/kernel/logger_chapter.html#log-level)
      - EMITTER_DEBOUNCE= # Debounce in ms before sending the message after a card has been read (optional, defaults to 1000)

  postgres:
    image: postgres:18.3
    volumes:
      - db:/var/lib/postgresql
    environment:
      - POSTGRES_PASSWORD= 

volumes:
  db:
```

## Developing

Requirements:

- Docker
- Nix

Nix will include `just` for task management, see [Justfile](./Justfile) for all available targets

```sh
just dev
```

The `dev` target will start the docker stack, install the dependencies, create the DB and start the server. In development, an MQTT broker is provided allowing for testing without the default configuration.

The app should be accessible on `http://localhost:4000`.

### Testing cards

In order to simulate cards, if you do not have a card reader, you can use the Webhook endpoint using the `just webhook` target like

```sh
just webhook <reader_name> <card_uid> <state>
```

- The reader name is the reading device, so any string with dash or underscore should work.
- The card UID is an hexadecimal string (like CB123CFA06)
- The state is either `inserted` or `removed`

#### LLM Notice

This application **was not** created using LLM. It was written by bare human hands (and a keyboard in the middle). 

However an LLM was used for the following things:

- Design the UI because my skills in design are yikes.
- Write the initial cover generation script.
