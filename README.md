# YetiForceCRM Docker

Official YetiForce Docker image

## Instructions

### Production

To start YetiForce in a production configuration:
1. In the `.env` file set the `HOSTNAME` to the where you will be running YetiForce and set `TLS_EMAIL` to your email address. Those settings will make sure that your website has a proper TLS certificate.
2. Download the YetiForce code: `git submodule update --init`.
3. Run `docker compose up -d`.
4. Go to `https://HOSTNAME` and go through the installation process. For your database settings, enter:
   - Address: db
   - Port: 3306
   - Username: yeti
   - Password: yeti
   - Database name: yetiforce

### Development

This image can also work in development mode. This mode is designed for actively making changes in YF itself. As such, it includes the following changes:
- YetiForce is run from the `./YetiForceCRM` directory
- MariaDB is available on `localhost:3306`
- PHP has a development configuration

This means that you will be able to make changes in `./YetiForceCRM`, see them reflected in your browser, and commit them normally.

To run in this mode:
1. Add a line with `127.0.0.1 yeti` to `/etc/hosts` on Unix or `C:\Windows\System32\drivers\etc\hosts` on Windows.
2. Download the YetiForce code: `git submodule update --init`.
3. Install YetiForce dependencies:
   ```shell
   cd ./YetiForceCRM
   install -m755 -d YetiForceCRM/config/Modules
   yarn install --modules-folder "./public_html/libraries" --ignore-optional --production=true
   cd public_html/src
   yarn install --ignore-optional --production=true
   cd ../..
   composer --no-interaction install --no-dev
   cd ..
   ```
4. Start the server with `docker compose -f docker-compose.yaml -f docker-compose.dev.yaml up -d`
4. Go to `https://HOSTNAME` and go through the installation process. For your database settings, enter:
   - Address: db
   - Port: 3306
   - Username: yeti
   - Password: yeti
   - Database name: yetiforce
