import { Hono } from "hono";

import { callProcedure } from "@/services/database";
import type { Procedure } from "@/types";
import { StatusCode, buildResponse } from "@/utils/buildResponse";

const router = new Hono();

router.post("/", async (c) => {
    const body: Omit<Procedure["register"]["input"], "profilePicture"> & {
        profilePicture?: File;
    } = await c.req.parseBody();

    // TODO: Handle binary (mungkin path atau key kalau nanti make service storage)
    const profilePicture = "";

    const queryResults = (
        await callProcedure("register", [
            body.name,
            body.email,
            body.gender,
            body.username,
            body.password,
            body.bio,
            profilePicture,
        ])
    ).result[0];

    return c.json(
        ...buildResponse(
            StatusCode.Created,
            "Register akun berhasil",
            queryResults,
        ),
    );
});

export { router as registerRouter };
