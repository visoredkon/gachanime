import app from "@/index";

export const postRequest = async (
    endpoint: string,
    payload: object | FormData,
    contentType: "application/json" | "multipart/form-data",
) => {
    const response = await app.request(endpoint, {
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

export const deleteRequest = async (endpoint: string, cookie: string) => {
    const response = await app.request(endpoint, {
        method: "DELETE",
        headers: {
            // biome-ignore lint/style/useNamingConvention: <explanation>
            Cookie: cookie,
        },
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
