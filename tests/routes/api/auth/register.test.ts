import {
    afterAll,
    beforeAll,
    beforeEach,
    describe,
    expect,
    test,
} from "bun:test";
import mysql from "mysql2/promise";

import app from "@/index";
import type { ResRegisterUser } from "@/types";
import {
    type ErrorResponse,
    type ResponseBody,
    StatusCode,
} from "@/utils/buildResponse";

const connection = await mysql.createConnection({
    host: Bun.env.MIGRATE_MYSQL_HOST,
    user: Bun.env.MIGRATE_MYSQL_USER,
    password: Bun.env.MIGRATE_MYSQL_PASSWORD,
    multipleStatements: true,
});

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

const postRequest = async (
    payload: object | FormData,
    contentType: "application/json" | "multipart/form-data",
) => {
    const response = await app.request("/api/auth/register", {
        method: "POST",
        body: (payload.constructor.name === "Object"
            ? JSON.stringify(payload)
            : payload) as string | FormData,
        headers:
            contentType === "application/json"
                ? { "Content-Type": contentType }
                : undefined,
    });

    const headersObj: { [key: string]: string } = {};
    response.headers.forEach((value, key) => {
        headersObj[key] = value;
    });

    const jsonRes: {
        status: number;
        header: { [key: string]: string };
        body: Response;
    } = {
        status: response.status,
        header: headersObj,
        body: response,
    };

    return jsonRes;
};

describe("auth: register", () => {
    const registerData = {
        name: "Kazuma",
        email: "kazuma@gachanime.com",
        gender: "Laki-Laki",
        username: "kazuma",
        password: "kazuma123",
        profilePicture: new File([], ""),
        bio: "",
    };

    const requestForm = new FormData();

    beforeEach(() => {
        for (const key in registerData) {
            if (Object.prototype.hasOwnProperty.call(registerData, key)) {
                const element = registerData[key as keyof typeof registerData];

                requestForm.set(key, element);
            }
        }
    });

    const registerPostRequest = (form: FormData) =>
        postRequest(form, "multipart/form-data");

    test("register berhasil", async () => {
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as Pick<
            ResponseBody,
            "message"
        > & { data: ResRegisterUser };

        expect(response.status).toBe(StatusCode.Created);

        expect(responseBody).toBeObject();
        expect(responseBody.message).toBe("Register akun berhasil");
        expect(responseBody.data).toBeObject();
        expect(responseBody.data.addedPlayerId).toBeInteger();
    });

    test("register gagal ketika `name` kosong", async () => {
        requestForm.delete("name");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe("Nama tidak boleh kosong");
    });

    test("register gagal ketika `email` kosong", async () => {
        requestForm.delete("email");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe("Email tidak valid");
    });

    test("register gagal ketika `email` tidak valid", async () => {
        requestForm.set("email", "kazuma@");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe("Email tidak valid");
    });

    test("register gagal ketika `gender` kosong", async () => {
        requestForm.delete("gender");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe("Gender tidak valid");
    });

    test("register gagal ketika `gender` tidak valid (bukan Laki-Laki atau Perempuan)", async () => {
        requestForm.set("gender", "Cowok");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe("Gender tidak valid");
    });

    test("register gagal ketika `username` kosong", async () => {
        requestForm.delete("username");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe(
            "Username tidak boleh kosong atau lebih dari 50 karakter",
        );
    });

    test("register gagal ketika `username` tidak valid (kurang dari 3 karakter)", async () => {
        requestForm.set("username", "k");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe(
            "Username tidak boleh kosong atau lebih dari 50 karakter",
        );
    });

    test("register gagal ketika `username` tidak valid (lebih dari 50 karakter)", async () => {
        requestForm.set(
            "username",
            "123456789123456789123456789123456789123456789123456789",
        );
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe(
            "Username tidak boleh kosong atau lebih dari 50 karakter",
        );
    });

    test("register gagal ketika `password` kosong", async () => {
        requestForm.delete("password");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe("Panjang password minimal 8 karakter");
    });

    test("register gagal ketika `password` tidak valid (kurang dari 8 karakter)", async () => {
        requestForm.set("password", "kazuma");
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe("Panjang password minimal 8 karakter");
    });

    test("register gagal ketika `username` tidak tersedia", async () => {
        const response = await registerPostRequest(requestForm);

        const responseBody = (await response.body.json()) as ErrorResponse;

        expect(response.status).toBe(StatusCode.BadRequest);

        expect(responseBody).toBeObject();
        expect(responseBody.errors).toBe(
            "Username tidak tersedia (telah digunakan)",
        );
    });
});
