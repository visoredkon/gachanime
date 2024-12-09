import { callProcedure } from "@/services/database";
import { StatusCode, buildResponse } from "@/utils/buildResponse";
import { Hono } from "hono";
import { adminsRouter } from "./admins";
import { playersRouter } from "./players";

const router = new Hono();

router.get("/", async (c) => {
    const isOnlyDeleted = c.req.query("only_deleted") === "true";
    const isWithDeleted = c.req.query("with_deleted") === "true";

    const queryResults = (
        await callProcedure("get_users", [isOnlyDeleted, isWithDeleted])
    ).results;

    if (!queryResults.length) {
        return c.json(
            ...buildResponse(StatusCode.Ok, "Tidak ada users yang ditemukan"),
        );
    }

    return c.json(
        ...buildResponse(
            StatusCode.Created,
            "Daftar users berhasil diambil",
            queryResults,
        ),
    );
});

router.route("/admins", adminsRouter);
router.route("/players", playersRouter);

export { router as usersRouter };
