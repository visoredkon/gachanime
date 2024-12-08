import { Faker, base, en, en_US, id_ID } from "@faker-js/faker";

export const faker = new Faker({
    locale: [base, en, en_US, id_ID],
});
