export enum StatusCode {
    Ok = 200,
    Created = 201,
    BadRequest = 400,
    Unauthorized = 401,
    Forbidden = 403,
    NotFound = 404,
    Conflict = 409,
    InternalServerError = 500,
}

export type SuccessResponse = {
    message: string;
    data?: Record<string, unknown> | Record<string, unknown>[];
};

export type ErrorResponse = {
    errors: string;
};

export type ResponseBody = {
    message: string;
    data?: Record<string, unknown> | Record<string, unknown>[];
};

export const buildResponse = (
    code: StatusCode,
    message: string,
    data?: Record<string, unknown> | Record<string, unknown>[],
): [SuccessResponse | ErrorResponse, StatusCode] => {
    const response: Partial<SuccessResponse & ErrorResponse> = {};

    if (code === StatusCode.Ok || code === StatusCode.Created) {
        response.message = message;
        response.data = data;
    } else {
        response.errors = message;
    }

    return [response as SuccessResponse | ErrorResponse, code];
};
