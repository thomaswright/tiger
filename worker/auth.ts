import { createRemoteJWKSet, jwtVerify } from "jose";
import type { UserIdentity } from "../src/shared/domain";

export interface AuthEnv {
  POLICY_AUD?: string;
  TEAM_DOMAIN?: string;
  TIGER_DEV_USER_EMAIL?: string;
  TIGER_DEV_USER_ID?: string;
}

export class AuthError extends Error {
  readonly status: 401 | 503;

  constructor(message: string, status: 401 | 503) {
    super(message);
    this.status = status;
  }
}

let cachedTeamDomain: string | undefined;
let cachedJwks: ReturnType<typeof createRemoteJWKSet> | undefined;

const isLocalHostname = (hostname: string) =>
  hostname === "localhost" ||
  hostname === "127.0.0.1" ||
  hostname === "[::1]";

const getJwks = (teamDomain: string) => {
  if (!cachedJwks || cachedTeamDomain !== teamDomain) {
    cachedTeamDomain = teamDomain;
    cachedJwks = createRemoteJWKSet(
      new URL(`${teamDomain}/cdn-cgi/access/certs`),
    );
  }

  return cachedJwks;
};

export async function authenticate(
  request: Request,
  env: AuthEnv,
): Promise<UserIdentity> {
  const hostname = new URL(request.url).hostname;

  if (isLocalHostname(hostname) && env.TIGER_DEV_USER_ID) {
    return {
      id: env.TIGER_DEV_USER_ID,
      email: env.TIGER_DEV_USER_EMAIL ?? "local@tiger.invalid",
    };
  }

  const teamDomain = env.TEAM_DOMAIN?.replace(/\/$/, "");
  if (!teamDomain || !env.POLICY_AUD) {
    throw new AuthError("Cloudflare Access is not configured", 503);
  }

  const token = request.headers.get("cf-access-jwt-assertion");
  if (!token) {
    throw new AuthError("Authentication required", 401);
  }

  try {
    const { payload } = await jwtVerify(token, getJwks(teamDomain), {
      audience: env.POLICY_AUD,
      issuer: teamDomain,
    });

    if (
      payload.type !== "app" ||
      typeof payload.sub !== "string" ||
      payload.sub.length === 0 ||
      typeof payload.email !== "string"
    ) {
      throw new Error("Access token does not contain a user identity");
    }

    return { id: payload.sub, email: payload.email };
  } catch {
    throw new AuthError("Invalid Cloudflare Access token", 401);
  }
}
