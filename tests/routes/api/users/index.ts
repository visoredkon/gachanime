import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import type { Procedure } from "@/types";
import { type ResponseBody, StatusCode } from "@/utils/buildResponse";
import { seeders } from "../../../../utils/seeders";
import { getRequest, postRequest } from "../../../../utils/tests/requests";

beforeAll(async () => {
    await seeders("drop");
    await seeders("seed");
});

afterAll(async () => {
    await seeders("drop");
});

describe("users: get users", () => {
    test("berhasil mendapatkan data users", async () => {
        const loginData = {
            username: "admin1",
            password: "password",
        } as { username: string; password: string };

        const responseLogin = await postRequest(
            "/api/auth/login",
            loginData,
            "application/json",
        );
        const loginToken = responseLogin.header["set-cookie"];

        const response = await getRequest("/api/users", loginToken);

        const responseBody = (await response.body.json()) as Pick<
            ResponseBody,
            "message"
        > & { data: Procedure["get_users"]["output"][] };

        expect(response.status).toBe(StatusCode.Ok);

        expect(responseBody).toBeObject();
        expect(responseBody.message).toBe("Daftar users berhasil diambil");
        expect(responseBody.data).toBeArray();
        expect(responseBody.data.length).toBeGreaterThanOrEqual(1);
    });
});
