import { Hono } from "hono";
import { setCookie } from "hono/cookie";
import { sign } from "hono/jwt";

import { callProcedure } from "@/services/database";
import type { Procedure } from "@/types";
import { StatusCode, buildResponse } from "@/utils/buildResponse";

const router = new Hono();

router.post("/", async (c) => {
    const body: Procedure["login"]["input"] = await c.req.json();

    const queryResults = (
        await callProcedure("login", [body.username, body.password])
    ).results[0];

    setCookie(
        c,
        "token",
        await sign(queryResults, Bun.env.JWT_SECRET_KEY, "HS512"),
        {
            httpOnly: true,
            maxAge: 3_600,
            path: "/",
            sameSite: "strict",
            secure: Bun.env.BUN_ENV === "production",
        },
    );

    return c.json(
        ...buildResponse(StatusCode.Ok, "Login berhasil", queryResults),
    );
});

export { router as loginRouter };
