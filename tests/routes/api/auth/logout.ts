import { afterAll, beforeAll, describe, expect, test } from "bun:test";

import {
    type ErrorResponse,
    type ResponseBody,
    StatusCode,
} from "@/utils/buildResponse";
import { connection } from "../../../../utils/connection";
import { deleteRequest, postRequest } from "../../../../utils/tests/requests";

beforeAll(async () => {
    await connection.query(
        await Bun.file(`${require.resolve("../../../../queries.sql")}`).text(),
    );
});

afterAll(async () => {
    await connection.query(
        await Bun.file(`${require.resolve("../../../../queries.sql")}`).text(),
    );
});

describe("auth: logout", () => {
    test("logout berhasil", async () => {
        const loginData = {
            username: "kazuma",
            password: "kazuma123",
        } as { username: string; password: string };

        const responseLogin = await postRequest(
            "/api/auth/login",
            loginData,
            "application/json",
        );
        const loginToken = responseLogin.header["set-cookie"];

        const response = await deleteRequest("/api/auth/logout", loginToken);

        const responseBody = (await response.body.json()) as Pick<
            ResponseBody,
            "message"
        >;

        expect(response.status).toBe(StatusCode.Ok);

        expect(responseBody).toBeObject();
        expect(responseBody.message).toBe("Logout berhasil");
    });

    test("logout gagal ketika tidak memiliki token yang valid", async () => {
        const response = await deleteRequest("/api/auth/logout", "");

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.Unauthorized);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("no authorization included in request");
    });
});
