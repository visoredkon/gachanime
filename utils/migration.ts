import { parseArgs } from "node:util";

import { seeders } from "./seeders";

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
            await seeders(action);
            return process.exit(0);
        }

        if (action === "all") {
            await seeders("drop");
            await seeders("seed");
            return process.exit(0);
        }

        console.error('Use "drop", "seed" or "all".');
    } catch (error) {
        console.error(error);
        return process.exit(1);
    }
};

main(action);
