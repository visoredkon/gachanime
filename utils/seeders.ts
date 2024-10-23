import { parseArgs } from "node:util";

async function manipulateDatabase(action: "seed" | "drop") {
    const operations = {
        seed: async () => {
            const inserts: never[] = [];

            for (const insert of inserts) {
                await insert;
            }

            console.info("Database seeded!");
        },
        drop: async () => {
            const drops: never[] = [];

            for (const del of drops) {
                await del;
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
