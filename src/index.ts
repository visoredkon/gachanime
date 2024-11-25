import { RouterApi } from "@/routes/api";
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { StatusCode, buildResponse } from "./utils/buildResponse";

const app = new Hono();

app.notFound((c) => {
    return c.json(...buildResponse(StatusCode.NotFound, "Not found"));
});

app.onError((err, c) => {
    if (err instanceof HTTPException) {
        return c.json(...buildResponse(err.status as StatusCode, err.message));
    }

    if ((err as { sqlState: number } & typeof err).sqlState) {
        return c.json(...buildResponse(StatusCode.BadRequest, err.message));
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
};
