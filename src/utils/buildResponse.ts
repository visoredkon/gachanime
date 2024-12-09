const StatusCode = {
    Ok: 200,
    Created: 201,
    BadRequest: 400,
    Unauthorized: 401,
    Forbidden: 403,
    NotFound: 404,
    Conflict: 409,
    InternalServerError: 500,
} as const;

type StatusCodeType = (typeof StatusCode)[keyof typeof StatusCode];

type SuccessResponse = {
    message: string;
    data?: Record<string, unknown> | Record<string, unknown>[];
};

type ErrorResponse = {
    error: string;
};

type ResponseBody = {
    message: string;
    data?: Record<string, unknown> | Record<string, unknown>[];
};

const buildResponse = (
    code: StatusCodeType,
    message: string,
    data?: Record<string, unknown> | Record<string, unknown>[],
): [SuccessResponse | ErrorResponse, StatusCodeType] => {
    const response: Partial<SuccessResponse & ErrorResponse> = {};

    if (code === StatusCode.Ok || code === StatusCode.Created) {
        response.message = message;
        response.data = data;
    } else if (code === StatusCode.InternalServerError) {
        response.error =
            message ||
            "Terjadi galat pada server. Hubungi admin untuk melaporkan galat";
    } else {
        response.error = message;
    }

    return [response as SuccessResponse | ErrorResponse, code];
};

const onlyAdmin = buildResponse(
    StatusCode.Unauthorized,
    "Unauthorized, hanya admin yang dapat melakukan hal ini",
);

export {
    StatusCode,
    type StatusCodeType,
    type SuccessResponse,
    type ErrorResponse,
    type ResponseBody,
    buildResponse,
    onlyAdmin,
};
