import mysql from "mysql2/promise";

export const connection = mysql.createPool({
    host: Bun.env.MIGRATE_MYSQL_HOST,
    user: Bun.env.MIGRATE_MYSQL_USER,
    password: Bun.env.MIGRATE_MYSQL_PASSWORD,
    multipleStatements: true,
});
