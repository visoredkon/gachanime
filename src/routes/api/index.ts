import { isAuthenticated } from "@/middlewares/authentication";
import { Hono } from "hono";
import { authRouter } from "./auth";

const router = new Hono();

router.route("/auth", authRouter);
router.use(isAuthenticated);

export { router as RouterApi };
