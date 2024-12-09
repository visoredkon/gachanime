import { Hono } from "hono";

import { authentication } from "@/middlewares/authentication";
import { authRouter } from "./auth";
import { usersRouter } from "./users";

const router = new Hono();

router.route("/auth", authRouter);
router.use(authentication);
router.route("/users", usersRouter);

export { router as RouterApi };
