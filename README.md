# Tiger

Tiger is a personal todo application built with React, Cloudflare Workers, D1,
and Cloudflare Access.

## Local development

Install dependencies:

```sh
npm install
```

Create the local-only identity configuration:

```sh
cp .dev.vars.example .dev.vars
```

Apply pending migrations to the local D1 database:

```sh
npm run db:migrate:local
```

Start the React client and Worker runtime together:

```sh
npm run dev
```

The development identity is accepted only for requests whose hostname is
`localhost`, `127.0.0.1`, or `::1`. Non-local requests require a valid
Cloudflare Access JWT.

## Checks

```sh
npm run build
npm run lint
npm test
npm audit
```

## Production configuration

Before deployment:

1. Create the production D1 database and replace the placeholder database ID
   in `wrangler.jsonc`.
2. Apply D1 migrations with Wrangler's `--remote` flag.
3. Put the application hostname behind Cloudflare Access.
4. Configure `TEAM_DOMAIN` and `POLICY_AUD` for the Worker.

The Worker validates `Cf-Access-Jwt-Assertion` before serving personal data.
