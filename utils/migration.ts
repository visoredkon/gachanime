import { parseArgs } from "node:util";
import mysql from "mysql2/promise";

const connection = await mysql.createConnection({
    host: Bun.env.MIGRATE_MYSQL_HOST,
    user: Bun.env.MIGRATE_MYSQL_USER,
    password: Bun.env.MIGRATE_MYSQL_PASSWORD,
    multipleStatements: true,
});

async function manipulateDatabase(action: "seed" | "drop") {
    const operations = {
        // seed: async () => {
        //     const inserts = [];

        //     for (const insert of inserts) {
        //         await connection.query(insert);
        //     }

        //     console.info("Database seeded!");
        // },
        drop: async () => {
            const drops = [
                await Bun.file(`${require.resolve("../queries.sql")}`).text(),
            ];

            for (const drop of drops) {
                await connection.query(drop);
            }

            console.info("Data dropped!");
        },
    };

    // await operations[action]();
    await operations[action as "drop"]();
}

const { values } = parseArgs({
    args: Bun.argv,
    options: {
        action: { type: "string", short: "a" },
    },
    strict: true,
    allowPositionals: true,
});

const { action } = values;

const main = async (action: string | undefined) => {
    try {
        if (action === "seed" || action === "drop") {
            await manipulateDatabase(action);
            return process.exit(0);
        }

        if (action === "all") {
            await manipulateDatabase("drop");
            await manipulateDatabase("seed");
            return process.exit(0);
        }

        console.error('Use "drop", "seed" or "all".');
    } catch (error) {
        console.error(error);
        return process.exit(1);
    }
};

main(action);
