import { Hono } from "hono";

import { callProcedure } from "@/services/database";
import { StatusCode, buildResponse, onlyAdmin } from "@/utils/buildResponse";
import { playerRouter } from "./:id";

const router = new Hono();

router.get("/", async (c) => {
    const payload = c.get("jwtPayload");

    if (!payload) {
        return c.json(
            ...buildResponse(StatusCode.Unauthorized, "Unauthorized"),
        );
    }

    const filter = c.req.query("filter");
    const isOnlyDeleted = c.req.query("only_deleted") === "true";
    const isWithDeleted = c.req.query("with_deleted") === "true";

    if ((isOnlyDeleted || isWithDeleted) && payload.role !== "admin") {
        return c.json(...onlyAdmin);
    }

    const procedureName = filter ? "find_players" : "get_players";
    const procedureArgs = {
        // biome-ignore lint/style/useNamingConvention: <explanation>
        find_players: [filter, isOnlyDeleted, isWithDeleted],
        // biome-ignore lint/style/useNamingConvention: <explanation>
        get_players: [isOnlyDeleted, isWithDeleted],
    };

    const queryResults = (
        await callProcedure(procedureName, procedureArgs[procedureName] as [])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(
                StatusCode.Ok,
                filter
                    ? `Tidak ada players dengan keyword "${filter}" yang ditemukan`
                    : "Tidak ada players yang ditemukan",
            ),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            filter
                ? `Daftar players dengan keyword "${filter}" berhasil diambil`
                : "Daftar players berhasil diambil",
            queryResults,
        ),
    );
});

router.get("/rank", async (c) => {
    const type = c.req.query("type");
    const limit = c.req.query("limit");

    if (!type) {
        return c.json(
            ...buildResponse(
                StatusCode.BadRequest,
                "Parameter type tidak boleh kosong",
            ),
        );
    }

    if (limit && Number.isNaN(Number(limit))) {
        return c.json(
            ...buildResponse(
                StatusCode.BadRequest,
                "Parameter limit harus berupa angka",
            ),
        );
    }

    if (type !== "exp" && type !== "money") {
        return c.json(
            ...buildResponse(
                StatusCode.BadRequest,
                'Parameter type hanya menerima "exp" atau "money"',
            ),
        );
    }

    const queryResults = (
        await callProcedure("get_players_rank", [type, Number(limit)])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(StatusCode.Ok, "Tidak ada player untuk diranking"),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            "Ranking player berhasil diambil",
            queryResults,
        ),
    );
});

router.route("/:id", playerRouter);

export { router as playersRouter };
