import type { Procedure } from "@/types";
import { faker } from "../faker";

export const powers: Procedure["add_power"]["input"][] = Array.from(
    { length: 10 },
    () => {
        return {
            name: faker.vehicle.vehicle(),
            description: faker.lorem.sentence(),
            price: faker.helpers.rangeToNumber({
                min: 10,
                max: 100,
            }) as unknown as bigint,
        };
    },
);
