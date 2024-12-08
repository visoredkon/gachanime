import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { logger } from "hono/logger";
import type { Variables } from "hono/types";

import { RouterApi } from "@/routes/api";
import type { SqlError } from "./types";
import {
    StatusCode,
    type StatusCodeType,
    buildResponse,
} from "./utils/buildResponse";
import { sqlStateType } from "./utils/sqlStateType";

// biome-ignore lint/style/useNamingConvention: <explanation>
const app = new Hono<{ Variables: Variables }>();

app.use(logger());

app.notFound((c) => {
    return c.json(
        ...buildResponse(StatusCode.NotFound, "Endpoint tidak ditemukan"),
    );
});

app.onError((err, c) => {
    if (err instanceof HTTPException) {
        return c.json(
            ...buildResponse(err.status as StatusCodeType, err.message),
        );
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

        return c.json(...buildResponse(StatusCode.InternalServerError, ""));
    }

    console.error(err);

    return c.json(...buildResponse(StatusCode.InternalServerError, ""));
});

app.route("/api", RouterApi);

export default {
    port: Bun.env.PORT,
    fetch: app.fetch,
    request: app.request,
};
