import { callProcedure } from "@/services/database";
import type { Procedure } from "@/types";
import { StatusCode, buildResponse, onlyAdmin } from "@/utils/buildResponse";
import { Hono } from "hono";
import { characterRouter } from "./:id";

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

    const procedureName = filter ? "find_characters" : "get_characters";
    const procedureArgs = {
        // biome-ignore lint/style/useNamingConvention: <explanation>
        find_characters: [filter, isOnlyDeleted, isWithDeleted],
        // biome-ignore lint/style/useNamingConvention: <explanation>
        get_characters: [isOnlyDeleted, isWithDeleted],
    };

    const queryResults = (
        await callProcedure(procedureName, procedureArgs[procedureName] as [])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(
                StatusCode.Ok,
                filter
                    ? `Tidak ada characters dengan keyword "${filter}" yang ditemukan`
                    : "Tidak ada characters yang ditemukan",
            ),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            filter
                ? `Daftar characters dengan keyword "${filter}" berhasil diambil`
                : "Daftar characters berhasil diambil",
            queryResults,
        ),
    );
});

router.post("/", async (c) => {
    const payload = c.get("jwtPayload");

    if (!payload) {
        return c.json(
            ...buildResponse(StatusCode.Unauthorized, "Unauthorized"),
        );
    }

    if (payload.role !== "admin") {
        return c.json(...onlyAdmin);
    }

    const body: Procedure["add_character"]["input"] = await c.req.json();

    const queryResults = (
        await callProcedure("add_character", [
            body.name,
            body.description,
            body.exp,
        ])
    ).results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, ""));
    }

    return c.json(...buildResponse(StatusCode.Ok, "", queryResults));
});

router.route("/:id", characterRouter);

export { router as charactersRouter };
