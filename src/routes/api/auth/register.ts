import { callProcedure } from "@/services/database";
import type { ReqRegisterUser, ResRegisterUser } from "@/types";
import { StatusCode, buildResponse } from "@/utils/buildResponse";
import { Hono } from "hono";

const router = new Hono();

router.post("/", async (c) => {
    const body: ReqRegisterUser = await c.req.json();

    const queryResults = (
        await callProcedure<ResRegisterUser>("register", [
            body.name,
            body.email,
            body.gender,
            body.username,
            body.password,
            body.profilePicture ?? null,
            body.bio ?? null,
        ])
    ).result[0];

    const { addedPlayerId } = queryResults;

    return c.json(
        ...buildResponse(StatusCode.Created, "Register akun berhasil", {
            addedPlayerId,
        }),
    );
});

export { router as registerRouter };
