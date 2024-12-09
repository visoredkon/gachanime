import { Hono } from "hono";

import { callProcedure } from "@/services/database";
import { StatusCode, buildResponse } from "@/utils/buildResponse";

const router = new Hono();

router.get("/", async (c) => {
    const isOnlyDeleted = c.req.query("only_deleted") === "true";
    const isWithDeleted = c.req.query("with_deleted") === "true";

    const queryResults = (
        await callProcedure("get_players", [isOnlyDeleted, isWithDeleted])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(StatusCode.Ok, "Tidak ada players yang ditemukan"),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Created,
            "Daftar players berhasil diambil",
            queryResults,
        ),
    );
});

export { router as playersRouter };
