import { Hono } from "hono";

import { callProcedure } from "@/services/database";
import type { Procedure } from "@/types";
import { StatusCode, buildResponse } from "@/utils/buildResponse";

const router = new Hono();

router.post("/", async (c) => {
    const body: Procedure["register"]["input"] = await c.req.json();

    const queryResults = (
        await callProcedure("register", [
            body.name,
            body.email,
            body.gender,
            body.username,
            body.password,
            body.bio,
            "player",
        ])
    ).results[0];

    return c.json(
        ...buildResponse(
            StatusCode.Created,
            "Register akun berhasil",
            queryResults,
        ),
    );
});

export { router as registerRouter };
