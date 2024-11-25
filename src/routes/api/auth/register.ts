import { callProcedure } from "@/services/database";
import type { RegisterUser } from "@/types";
import { StatusCode, buildResponse } from "@/utils/buildResponse";
import { Hono } from "hono";

const router = new Hono();

router.post("/", async (c) => {
    const body: RegisterUser = await c.req.json();

    const queryResults = (
        await callProcedure<{ addedPlayerId: number }>("register", [
            body.name,
            body.email,
            body.gender,
            body.username,
            body.password,
            body.profilePicture ?? null,
            body.bio ?? null,
        ])
    ).result[0];

    return c.json(
        ...buildResponse(StatusCode.Ok, "Login success", {
            queryResults,
        }),
    );
});

export { router as registerRouter };
