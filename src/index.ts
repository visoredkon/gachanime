import { RouterApi } from "@/routes/api";
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { logger } from "hono/logger";
import type { SqlError } from "./types";
import { StatusCode, buildResponse } from "./utils/buildResponse";
import { sqlStateType } from "./utils/sqlStateType";

const app = new Hono();

app.use(logger());

app.notFound((c) => {
    return c.json(...buildResponse(StatusCode.NotFound, "Not found"));
});

app.onError((err, c) => {
    if (err instanceof HTTPException) {
        return c.json(...buildResponse(err.status as StatusCode, err.message));
    }

    if ((err as SqlError).sqlState) {
        const sqlState = sqlStateType(Number((err as SqlError).sqlState));

        if (
            sqlState === "Defined Exception" &&
            !err.message.startsWith("Terjadi galat pada server")
        ) {
            return c.json(...buildResponse(StatusCode.BadRequest, err.message));
        }

        console.error(sqlState, err);

        return c.json(
            ...buildResponse(StatusCode.InternalServerError, err.message),
        );
    }

    console.error(err);

    return c.json(
        ...buildResponse(
            StatusCode.InternalServerError,
            "Internal server error",
        ),
    );
});

app.route("/api", RouterApi);

export default {
    port: Bun.env.PORT,
    fetch: app.fetch,
    request: app.request,
};
