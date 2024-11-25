import { StatusCode, buildResponse } from "@/utils/buildResponse";
import { Hono } from "hono";
import { deleteCookie } from "hono/cookie";

const router = new Hono();

router.delete("/", (c) => {
    deleteCookie(c, "token");

    return c.json(...buildResponse(StatusCode.Ok, "Logout success"));
});

export { router as logoutRouter };
