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

type SuccessResponse = {
    message: string;
    data?: object;
};

type ErrorResponse = {
    errors: string;
};

export const buildResponse = (
    code: StatusCode,
    message: string,
    data?: object,
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
