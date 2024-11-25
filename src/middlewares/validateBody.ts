import { StatusCode } from "@/utils/buildResponse";
import type { MiddlewareHandler } from "hono";
import { HTTPException } from "hono/http-exception";

export const validateBody: MiddlewareHandler = async (c, next) => {
    const method = c.req.method;
    const contentType = c.req.header("content-type")?.split(";")[0];

    const allowedContentTypes = ["application/json", "multipart/form-data"];

    if (method !== "POST" && method !== "PUT") {
        return next();
    }

    if (!allowedContentTypes.includes(contentType as string)) {
        throw new HTTPException(StatusCode.BadRequest, {
            message: "Content-Type tidak valid!",
        });
    }

    if (contentType === "multipart/form-data") {
        return next();
    }

    return new Promise((resolve, reject) => {
        c.req
            .json()
            .then((_body) => {
                resolve(next());
            })
            .catch((_err) => {
                reject(
                    new HTTPException(StatusCode.BadRequest, {
                        message: "Body tidak valid!",
                    }),
                );
            });
    });
};
