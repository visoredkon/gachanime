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

    const queryResults = (await callProcedure("get_power_by_id", [Number(id)]))
        .results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, "Power tidak ditemukan"));
    }

    if (queryResults[0].deleted_at) {
        if (payload.role !== "admin") {
            return c.json(
                ...buildResponse(StatusCode.Ok, "Power tidak ditemukan"),
            );
        }
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            "Data power berhasil diambil",
            queryResults[0],
        ),
    );
});

router.post("/", async (c) => {
    const payload = c.get("jwtPayload");

    if (!payload && payload.role !== "player") {
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

    if (!Number(payload.id)) {
        return c.json(
            ...buildResponse(StatusCode.BadRequest, "Player ID tidak valid"),
        );
    }

    const queryResults = (
        await callProcedure("buy_power", [Number(payload.id), Number(id)])
    ).results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, "Beli power gagal"));
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            "Power berhasil dibeli",
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

    const body: Procedure["update_power_by_id"]["input"] = await c.req.json();

    const queryResults = (
        await callProcedure("update_power_by_id", [
            Number(id),
            body.name,
            body.description,
            body.price,
        ])
    ).results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, "Power tidak ditemukan"));
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            "Data power berhasil di-update",
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
        await callProcedure("delete_power_by_id", [Number(id), isHard])
    ).results;

    if (!queryResults.length) {
        return c.json(...buildResponse(StatusCode.Ok, "Power tidak ditemukan"));
    }

    return c.json(
        ...buildResponse(
            StatusCode.Ok,
            "Data power berhasil di-update",
            queryResults,
        ),
    );
});

export { router as powerRouter };
