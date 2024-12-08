import {
    afterAll,
    beforeAll,
    beforeEach,
    describe,
    expect,
    test,
} from "bun:test";

import type { Procedure } from "@/types";
import {
    type ErrorResponse,
    type ResponseBody,
    StatusCode,
} from "@/utils/buildResponse";
import { verify } from "hono/jwt";
import { connection } from "../../../../utils/connection";
import { postRequest } from "../../../../utils/tests/requests";

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

describe("auth: login", () => {
    const loginData = {
        username: "kazuma",
        password: "kazuma123",
    } as { username: string | null; password: string | null };

    const requestBody: Partial<typeof loginData> = new Object();

    beforeEach(() => {
        for (const key in loginData) {
            if (Object.prototype.hasOwnProperty.call(loginData, key)) {
                const element = loginData[key as keyof typeof loginData];

                requestBody[key as keyof typeof loginData] = element;
            }
        }
    });

    const loginPostRequest = () =>
        postRequest("/api/auth/login", loginData, "application/json");

    test("login berhasil", async () => {
        const response = await loginPostRequest();

        const responseBody = (await response.body.json()) as Pick<
            ResponseBody,
            "message"
        > & { data: Procedure["login"]["output"] };
        const responseToken = response.header["set-cookie"].split(";")[0];

        expect(response.status).toBe(StatusCode.Ok);

        expect(responseToken).toContain("token=");
        expect(
            await verify(
                responseToken.split("=")[1],
                Bun.env.JWT_SECRET_KEY,
                "HS512",
            ),
        ).toMatchObject({
            id: responseBody.data.id,
            name: responseBody.data.name,
            username: responseBody.data.username,
            role: responseBody.data.role,
        });

        expect(responseBody).toBeObject();
        expect(responseBody.message).toBe("Login berhasil");
        expect(responseBody.data).toBeObject();
        expect(responseBody.data.id).toBeInteger();
        expect(responseBody.data.name).toBeString();
        expect(responseBody.data.username).toBeString();
        expect(["player", "admin"].includes(responseBody.data.role)).toBeTrue();
    });

    test("login gagal ketika `username` kosong", async () => {
        loginData.username = null;
        const response = await loginPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Username atau password salah");
    });

    test("login gagal ketika `username` tidak valid (kurang dari 3 karakter)", async () => {
        loginData.username = "k";
        const response = await loginPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Username atau password salah");
    });

    test("login gagal ketika `username` tidak valid (lebih dari 50 karakter)", async () => {
        loginData.username =
            "123456789123456789123456789123456789123456789123456789";
        const response = await loginPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Username atau password salah");
    });

    test("login gagal ketika `username` valid namun tidak terdaftar", async () => {
        loginData.username = "kaz";
        const response = await loginPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Username atau password salah");
    });
});
