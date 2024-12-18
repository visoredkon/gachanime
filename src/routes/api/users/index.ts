import { callProcedure } from "@/services/database";
import { StatusCode, buildResponse, onlyAdmin } from "@/utils/buildResponse";
import { Hono } from "hono";
import { adminsRouter } from "./admins";
import { playersRouter } from "./players";

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

    const procedureName = filter ? "find_users" : "get_users";
    const procedureArgs = {
        // biome-ignore lint/style/useNamingConvention: <explanation>
        find_users: [filter, isOnlyDeleted, isWithDeleted],
        // biome-ignore lint/style/useNamingConvention: <explanation>
        get_users: [isOnlyDeleted, isWithDeleted],
    };

    const queryResults = (
        await callProcedure(procedureName, procedureArgs[procedureName] as [])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(
                StatusCode.Ok,
                filter
                    ? `Tidak ada users dengan keyword "${filter}" yang ditemukan`
                    : "Tidak ada users yang ditemukan",
            ),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            filter
                ? `Daftar users dengan keyword "${filter}" berhasil diambil`
                : "Daftar users berhasil diambil",
            queryResults,
        ),
    );
});

router.route("/admins", adminsRouter);
router.route("/players", playersRouter);

export { router as usersRouter };
