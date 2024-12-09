import { Hono } from "hono";

import { authentication } from "@/middlewares/authentication";
import { authRouter } from "./auth";
import { charactersRouter } from "./characters";
import { playRouter } from "./play";
import { powersRouter } from "./powers";
import { usersRouter } from "./users";

const router = new Hono();

router.route("/auth", authRouter);
router.use(authentication);
router.route("/users", usersRouter);
router.route("/characters", charactersRouter);
router.route("/powers", powersRouter);
router.route("/play", playRouter);

export { router as RouterApi };
