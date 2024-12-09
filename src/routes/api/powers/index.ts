import { callProcedure } from "@/services/database";
import type { Procedure } from "@/types";
import { StatusCode, buildResponse, onlyAdmin } from "@/utils/buildResponse";
import { Hono } from "hono";
import { powerRouter } from "./:id";

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

    const procedureName = filter ? "find_powers" : "get_powers";
    const procedureArgs = {
        // biome-ignore lint/style/useNamingConvention: <explanation>
        find_powers: [filter, isOnlyDeleted, isWithDeleted],
        // biome-ignore lint/style/useNamingConvention: <explanation>
        get_powers: [isOnlyDeleted, isWithDeleted],
    };

    const queryResults = (
        await callProcedure(procedureName, procedureArgs[procedureName] as [])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(
                StatusCode.Ok,
                filter
                    ? `Tidak ada powers dengan keyword "${filter}" yang ditemukan`
                    : "Tidak ada powers yang ditemukan",
            ),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            filter
                ? `Daftar powers dengan keyword "${filter}" berhasil diambil`
                : "Daftar powers berhasil diambil",
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

    const body: Procedure["add_power"]["input"] = await c.req.json();

    const queryResults = (
        await callProcedure("add_power", [
            body.name,
            body.description,
            body.price,
        ])
    ).results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, ""));
    }

    return c.json(...buildResponse(StatusCode.Ok, "", queryResults));
});

router.route("/:id", powerRouter);

export { router as powersRouter };
