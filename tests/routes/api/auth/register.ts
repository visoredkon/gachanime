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

describe("auth: register", () => {
    const registerData = {
        name: "Kazuma",
        email: "kazuma@gachanime.com",
        gender: "Laki-Laki",
        username: "kazuma",
        password: "kazuma123",
        bio: "",
    };

    const requestBody: Partial<typeof registerData> = {};

    beforeEach(() => {
        for (const key in registerData) {
            if (Object.prototype.hasOwnProperty.call(registerData, key)) {
                const element = registerData[key as keyof typeof registerData];

                requestBody[key as keyof typeof registerData] = element;
            }
        }
    });

    const registerPostRequest = () =>
        postRequest("/api/auth/register", requestBody, "multipart/form-data");

    test("register berhasil", async () => {
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as Pick<
            ResponseBody,
            "message"
        > & { data: Procedure["register"]["output"] };

        expect(response.status).toBe(StatusCode.Created);

        expect(responseBody).toBeObject();
        expect(responseBody.message).toBe("Register akun berhasil");
        expect(responseBody.data).toBeObject();
        expect(responseBody.data.addedPlayerId).toBeInteger();
    });

    test("register gagal ketika `name` kosong", async () => {
        requestBody.name = undefined;
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Nama tidak boleh kosong");
    });

    test("register gagal ketika `email` kosong", async () => {
        requestBody.email = undefined;
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Email tidak valid");
    });

    test("register gagal ketika `email` tidak valid", async () => {
        requestBody.email = "kazuma@";
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Email tidak valid");
    });

    test("register gagal ketika `email` telah digunakan", async () => {
        requestBody.username = "kazuma2";
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Email telah digunakan");
    });

    test("register gagal ketika `gender` kosong", async () => {
        requestBody.gender = undefined;
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Gender tidak valid");
    });

    test("register gagal ketika `gender` tidak valid (bukan Laki-Laki atau Perempuan)", async () => {
        requestBody.gender = "Cowok";
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Gender tidak valid");
    });

    test("register gagal ketika `username` kosong", async () => {
        requestBody.username = undefined;
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe(
            "Username tidak boleh kosong atau lebih dari 50 karakter",
        );
    });

    test("register gagal ketika `username` tidak valid (kurang dari 3 karakter)", async () => {
        requestBody.username = "k";
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe(
            "Username tidak boleh kosong atau lebih dari 50 karakter",
        );
    });

    test("register gagal ketika `username` tidak valid (lebih dari 50 karakter)", async () => {
        requestBody.username =
            "123456789123456789123456789123456789123456789123456789";
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe(
            "Username tidak boleh kosong atau lebih dari 50 karakter",
        );
    });

    test("register gagal ketika `password` kosong", async () => {
        requestBody.password = undefined;
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Panjang password minimal 8 karakter");
    });

    test("register gagal ketika `password` tidak valid (kurang dari 8 karakter)", async () => {
        requestBody.password = "kazuma";
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe("Panjang password minimal 8 karakter");
    });

    test("register gagal ketika `username` tidak tersedia", async () => {
        const response = await registerPostRequest();

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.error).toBe(
            "Username tidak tersedia (telah digunakan)",
        );
    });
});
