import { callProcedure } from "@/services/database";
import { connection } from "./connection";
import { data } from "./data";

export async function seeders(action: "seed" | "drop") {
    const operations = {
        seed: async () => {
            const inserts = {
                admins: data.admins,
                players: data.players,
                characters: data.characters,
                powers: data.powers,
            };

            for (const data of inserts.admins) {
                await callProcedure("register", [
                    data.name,
                    data.email,
                    data.gender,
                    data.username,
                    data.password,
                    data.bio,
                    "admin",
                ]);
            }

            for (const data of inserts.players) {
                await callProcedure("register", [
                    data.name,
                    data.email,
                    data.gender,
                    data.username,
                    data.password,
                    data.bio,
                    "player",
                ]);
            }

            for (const data of inserts.characters) {
                await callProcedure("add_character", [
                    data.name,
                    data.description,
                    data.exp,
                ]);
            }

            await callProcedure("add_power", [
                "+1 pull",
                "+1 kemampuan pull",
                50n,
            ]);

            await callProcedure("add_power", [
                "+1 claim",
                "+1 kemampuan claim",
                100n,
            ]);

            for (const data of inserts.powers) {
                await callProcedure("add_power", [
                    data.name,
                    data.description,
                    data.price,
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
