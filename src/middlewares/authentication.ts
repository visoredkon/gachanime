import type { MiddlewareHandler } from "hono";
import { jwt } from "hono/jwt";

export const authentication: MiddlewareHandler = jwt({
    alg: "HS512",
    cookie: "token",
    secret: Bun.env.JWT_SECRET_KEY,
});
