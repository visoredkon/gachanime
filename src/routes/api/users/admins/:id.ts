import { callProcedure } from "@/services/database";
import type { Procedure } from "@/types";
import { StatusCode, buildResponse, onlyAdmin } from "@/utils/buildResponse";
import { Hono } from "hono";

const router = new Hono();

router.get("/", async (c) => {
    const payload = c.get("jwtPayload");

    if (!payload) {
        return c.json(
            ...buildResponse(StatusCode.Unauthorized, "Unauthorized"),
        );
    }

    const id = c.req.param("id");

    if (!Number(id)) {
        return c.json(
            ...buildResponse(StatusCode.BadRequest, "ID tidak valid"),
        );
    }

    if (payload.id !== Number(id) && payload.role !== "admin") {
        return c.json(...onlyAdmin);
    }

    const queryResults = (await callProcedure("get_admin_by_id", [Number(id)]))
        .results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, "Admin tidak ditemukan"));
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            "Data admin berhasil diambil",
            queryResults[0],
        ),
    );
});

router.patch("/", async (c) => {
    const payload = c.get("jwtPayload");

    if (!payload) {
        return c.json(
            ...buildResponse(StatusCode.Unauthorized, "Unauthorized"),
        );
    }

    const id = c.req.param("id");

    if (!Number(id)) {
        return c.json(
            ...buildResponse(StatusCode.BadRequest, "ID tidak valid"),
        );
    }

    if (payload.id !== Number(id) && payload.role !== "admin") {
        return c.json(...onlyAdmin);
    }

    const body: Procedure["update_admin_by_id"]["input"] = await c.req.json();

    const queryResults = (
        await callProcedure("update_admin_by_id", [
            Number(id),
            body.name,
            body.email,
            body.gender,
            body.username,
            body.password,
            body.bio,
        ])
    ).results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, "Admin tidak ditemukan"));
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            "Data admin berhasil di-update",
            queryResults,
        ),
    );
});

router.delete("/", async (c) => {
    const payload = c.get("jwtPayload");

    if (!payload) {
        return c.json(
            ...buildResponse(StatusCode.Unauthorized, "Unauthorized"),
        );
    }

    const id = c.req.param("id");

    if (!Number(id)) {
        return c.json(
            ...buildResponse(StatusCode.BadRequest, "ID tidak valid"),
        );
    }

    if (payload.id !== Number(id) && payload.role !== "admin") {
        return c.json(...onlyAdmin);
    }

    const isHard = c.req.query("hard") === "true";

    const queryResults = (
        await callProcedure("delete_admin_by_id", [Number(id), isHard])
    ).results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, "Admin tidak ditemukan"));
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            "Data admin berhasil di-update",
            queryResults,
        ),
    );
});

export { router as adminRouter };
