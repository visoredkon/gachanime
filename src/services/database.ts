import type { Procedure, ValuesOf } from "@/types";
import mysql, { type ResultSetHeader } from "mysql2/promise";

const connection = mysql.createPool({
    host: Bun.env.MYSQL_HOST,
    user: Bun.env.MYSQL_USER,
    password: Bun.env.MYSQL_PASSWORD,
    database: Bun.env.MYSQL_DATABASE,
});

// biome-ignore lint/style/useNamingConvention: <explanation>
export const callProcedure = async <TProcedureName extends keyof Procedure>(
    procName: TProcedureName,
    procParams: ValuesOf<Procedure[TProcedureName]["input"]>,
): Promise<{
    results: Procedure[TProcedureName]["output"][];
    resultHeader: ResultSetHeader;
}> => {
    const [queryResults] = await connection.execute(
        `call ${procName}(${new Array(procParams.length).fill("?").join(" ,")})`,
        procParams.map((value) => value ?? null),
    );

    const [results, resultHeader] = queryResults as [
        Procedure[TProcedureName]["output"][],
        ResultSetHeader,
    ];

    return {
        results,
        resultHeader,
    };
};
