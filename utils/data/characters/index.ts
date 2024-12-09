import type { Procedure } from "@/types";
import { faker } from "../faker";

export const characters: Procedure["add_character"]["input"][] = Array.from(
    { length: 10 },
    () => {
        return {
            name: faker.animal.petName(),
            description: faker.lorem.sentence(),
            exp: faker.helpers.rangeToNumber({
                min: 10,
                max: 100,
            }) as unknown as bigint,
        };
    },
);
