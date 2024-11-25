import mysql, { type ResultSetHeader } from "mysql2/promise";

const connection = await mysql.createConnection({
    host: Bun.env.MYSQL_HOST,
    user: Bun.env.MYSQL_USER,
    password: Bun.env.MYSQL_PASSWORD,
    database: Bun.env.MYSQL_DATABASE,
});

export const callProcedure = async <T>(
    procName: string,
    procParams: (string | number | null)[],
): Promise<{ result: T[]; resultHeader: ResultSetHeader }> => {
    const [queryResults] = await connection.query(
        `call ${procName}(${new Array(procParams.length).fill("?").join(" ,")})`,
        procParams,
    );

    const [result, resultHeader] = queryResults as [T[], ResultSetHeader];

    return {
        result,
        resultHeader,
    };
};
