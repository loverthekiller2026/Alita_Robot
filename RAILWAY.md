# Deploy Alita Robot on Railway

Alita Robot is a Go Telegram group-management bot. Railway runs the bot as one
long-lived service, with PostgreSQL and Redis as separate Railway services.

## 1. Create the Railway project

1. Create a new Railway project and choose **Deploy from GitHub repo**.
2. Select `loverthekiller2026/Alita_Robot`.
3. Let Railway use the repository's `Dockerfile` and `railway.json`.
4. Add a PostgreSQL service and a Redis service to the same Railway project.

Do not deploy the bot as multiple replicas: Telegram long polling should have
only one active bot instance.

## 2. Link the database services

In the Alita Robot service, add these Railway reference variables (the service
names on the right must match the names shown in your Railway project):

| Variable | Value |
| --- | --- |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` |
| `REDIS_URL` | `${{Redis.REDIS_URL}}` |

If your Railway services have different names, replace `Postgres` and `Redis`
with their exact service names. Do not set `REDIS_ADDRESS` when using
`REDIS_URL`; `REDIS_ADDRESS` takes precedence in this application.

## 3. Add Telegram configuration

Set these variables in the Alita Robot service:

| Variable | Required value |
| --- | --- |
| `BOT_TOKEN` | Token from Telegram BotFather |
| `OWNER_ID` | Your numeric Telegram user ID |
| `MESSAGE_DUMP` | Numeric ID of the private log channel, usually starting with `-100` |
| `USE_WEBHOOKS` | `false` |
| `DROP_PENDING_UPDATES` | `true` (optional) |
| `ENABLED_LOCALES` | `en` (optional) |

Keep `USE_WEBHOOKS=false` for the recommended Railway setup. The bot then
uses Telegram long polling and does not need a public webhook domain or secret.
Railway supplies `PORT`; the app uses it for its HTTP health/metrics server.

Make sure the bot is added to the groups where it should work and has the
Telegram permissions required for the moderation features you enable.

## 4. Deploy and verify

1. Save the variables and trigger a deployment.
2. Open the deployment logs. A successful start should show database and cache
   initialization, bot initialization, the HTTP server, and polling startup.
3. Railway checks `/health`. That endpoint verifies both PostgreSQL and Redis,
   so the deployment is not considered healthy until both services respond.

## Notes

- Keep the Alita service at **one replica** to avoid Telegram polling conflicts.
- Do not commit `.env`, bot tokens, webhook secrets, or database credentials.
- The bot requires all three Telegram values: `BOT_TOKEN`, `OWNER_ID`, and
  `MESSAGE_DUMP`; it also requires `DATABASE_URL` and Redis connectivity.
- Optional webhook mode requires `USE_WEBHOOKS=true`, `WEBHOOK_DOMAIN`, and
  a strong `WEBHOOK_SECRET`. Do not enable it unless you have configured the
  Railway public domain and intend to use webhooks.
