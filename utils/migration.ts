import { parseArgs } from "node:util";

import { callProcedure } from "@/services/database";
import { connection } from "./connection";
import { data } from "./data";

async function manipulateDatabase(action: "seed" | "drop") {
    const operations = {
        seed: async () => {
            const inserts = {
                admins: data.admins,
                players: data.players,
            };

            for (const data of inserts.admins) {
                await connection.execute(
                    "insert into admins set admins.name = ?, admins.email = ?, admins.gender = ?, admins.username = ?, admins.password = hash(?), admins.bio = ?, admins.profile_picture = ?;",
                    [
                        data.name,
                        data.email,
                        data.gender,
                        data.username,
                        data.password,
                        data.bio,
                        data.profilePicture,
                    ],
                );
            }

            for (const data of inserts.players) {
                await callProcedure("register", [
                    data.name,
                    data.email,
                    data.gender,
                    data.username,
                    data.password,
                    data.bio,
                    data.profilePicture,
                ]);
            }

            console.info("Database seeded!");
        },
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

    await operations[action]();
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
