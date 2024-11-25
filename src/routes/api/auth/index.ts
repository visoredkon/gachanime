import { isAuthenticated } from "@/middlewares/authentication";
import { Hono } from "hono";
import { loginRouter } from "../../../../sandbox/login";
import { logoutRouter } from "./logout";
import { registerRouter } from "./register";

const router = new Hono();

router.route("/login", loginRouter);
router.route("/register", registerRouter);
router.use(isAuthenticated);
router.route("/logout", logoutRouter);

export { router as authRouter };
