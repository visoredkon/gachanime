import { Hono } from "hono";
import { deleteCookie } from "hono/cookie";

import { StatusCode, buildResponse } from "@/utils/buildResponse";

const router = new Hono();

router.delete("/", (c) => {
    deleteCookie(c, "token");

    return c.json(...buildResponse(StatusCode.Ok, "Logout berhasil"));
});

export { router as logoutRouter };
