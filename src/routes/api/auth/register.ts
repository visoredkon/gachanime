import { callProcedure } from "@/services/database";
import type { ReqRegisterUser, ResRegisterUser } from "@/types";
import { StatusCode, buildResponse } from "@/utils/buildResponse";
import { Hono } from "hono";

const router = new Hono();

router.post("/", async (c) => {
    const body: ReqRegisterUser = await c.req.parseBody();

    // TODO: Handle binary (mungkin path atau key kalau nanti make service storage)
    const profilePicture = "";

    const queryResults = (
        await callProcedure<ResRegisterUser>("register", [
            body.name,
            body.email,
            body.gender,
            body.username,
            body.password,
            body.bio ?? null,
            profilePicture,
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
