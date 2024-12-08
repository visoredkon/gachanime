import type { Procedure } from "@/types";
import { gender } from "../enums";
import { faker } from "../faker";

export const players: Procedure["register"]["input"][] = Array.from(
    { length: 10 },
    (_, i) => {
        const playerGender = faker.helpers.arrayElement([
            gender["Laki-laki"],
            gender.Perempuan,
        ]);
        const playerName = faker.person
            .fullName({
                sex: (() => {
                    // biome-ignore lint/style/useDefaultSwitchClause: <explanation>
                    switch (playerGender) {
                        case "Laki-laki":
                            return "male";

                        case "Perempuan":
                            return "female";
                    }
                })() as "male" | "female",
            })
            .split(" ");

        return {
            name: playerName.join(" "),
            email: faker.internet.email({
                firstName: playerName[0],
                lastName: playerName[1],
                provider: "gachanime.com",
            }),
            gender: playerGender,
            username: `player${i + 1}`,
            password: "password",
            bio: faker.person.bio(),
            profilePicture: "",
        };
    },
);
