import { Hono } from "hono";
import { adminsRouter } from "./admins";
import { playersRouter } from "./players";

const router = new Hono();

router.route("/admins", adminsRouter);
router.route("/players", playersRouter);

export { router as usersRouter };
