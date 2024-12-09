import { Hono } from "hono";

import { callProcedure } from "@/services/database";
import { StatusCode, buildResponse, onlyAdmin } from "@/utils/buildResponse";
import { adminRouter } from "./:id";

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

    const procedureName = filter ? "find_admins" : "get_admins";
    const procedureArgs = {
        // biome-ignore lint/style/useNamingConvention: <explanation>
        find_admins: [filter, isOnlyDeleted, isWithDeleted],
        // biome-ignore lint/style/useNamingConvention: <explanation>
        get_admins: [isOnlyDeleted, isWithDeleted],
    };

    const queryResults = (
        await callProcedure(procedureName, procedureArgs[procedureName] as [])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(
                StatusCode.Ok,
                filter
                    ? `Tidak ada admins dengan keyword "${filter}" yang ditemukan`
                    : "Tidak ada admins yang ditemukan",
            ),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            filter
                ? `Daftar admins dengan keyword "${filter}" berhasil diambil`
                : "Daftar admins berhasil diambil",
            queryResults,
        ),
    );
});

router.route("/:id", adminRouter);

export { router as adminsRouter };
