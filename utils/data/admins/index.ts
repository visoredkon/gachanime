import type { Procedure } from "@/types";
import { gender } from "../enums";
import { faker } from "../faker";

export const admins: (Procedure["register"]["input"] & {
    deletedAt: null | Date;
})[] = Array.from({ length: 10 }, (_, i) => {
    const adminGender = faker.helpers.arrayElement([
        gender["Laki-laki"],
        gender.Perempuan,
    ]);
    const adminName = faker.person
        .fullName({
            sex: (() => {
                // biome-ignore lint/style/useDefaultSwitchClause: <explanation>
                switch (adminGender) {
                    case "Laki-laki":
                        return "male";

                    case "Perempuan":
                        return "female";
                }
            })() as "male" | "female",
        })
        .split(" ");

    return {
        name: adminName.join(" "),
        email: faker.internet.email({
            firstName: adminName[0],
            lastName: adminName[1],
            provider: "gachanime.com",
        }),
        gender: adminGender,
        username: `admin${i + 1}`,
        password: "password",
        bio: faker.person.bio(),
        deletedAt: faker.helpers.arrayElement([null, new Date()]),
    };
});
