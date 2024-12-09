import { Hono } from "hono";

import { callProcedure } from "@/services/database";
import { StatusCode, buildResponse } from "@/utils/buildResponse";

const router = new Hono();

router.get("/:action", async (c) => {
    const payload = c.get("jwtPayload");

    if (!payload && payload.role !== "player") {
        return c.json(
            ...buildResponse(StatusCode.Unauthorized, "Unauthorized"),
        );
    }

    const action = c.req.param("action");

    if (action !== "gacha" && action !== "claim") {
        return c.json(
            ...buildResponse(StatusCode.BadRequest, "Action tidak valid"),
        );
    }

    const procedureName = {
        gacha: "gacha_character",
        claim: "claim_character",
    } as const;

    if (!Number(payload.id)) {
        return c.json(
            ...buildResponse(StatusCode.BadRequest, "ID tidak valid"),
        );
    }

    const queryResults = (
        await callProcedure(procedureName[action], [Number(payload.id)])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(StatusCode.Ok, `${action} character gagal`),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            `${action} character berhasil`,
            queryResults[0],
        ),
    );
});

export { router as playRouter };
