type ValuesOf<T> = T[keyof T][];

interface SqlError extends Error {
    sqlState: number;
}

type ProcedureDetails<Input, Output> = {
    input: Input;
    output: Output;
};

type GetUsers = ProcedureDetails<
    {
        onlyDeleted: boolean;
        withDeleted: boolean;
    },
    {
        id: number;
        name: string;
        username: string;
    }
>;

type GetUser = ProcedureDetails<
    {
        id: number;
    },
    {
        name: string;
        email: string;
        gender: "Laki-laki" | "Perempuan";
        username: string;
        bio?: string;
        role: "player" | "admin";
        created_at: Date;
        updated_at: Date | null;
        deleted_at: Date | null;
    }
>;

type UpdateUser = ProcedureDetails<
    {
        id: number;
        name: string;
        email: string;
        gender: "Laki-laki" | "Perempuan";
        username: string;
        password: string;
        bio?: string;
    },
    {
        id: number;
        updated_at: Date;
    }
>;

type DeleteUser = ProcedureDetails<
    {
        id: number;
        isHard: boolean;
    },
    {
        id: number;
        updated_at: Date;
    }
>;

type GetCharacters = ProcedureDetails<
    {
        onlyDeleted: boolean;
        withDeleted: boolean;
    },
    {
        id: number;
        name: string;
    }
>;

type GetCharacter = ProcedureDetails<
    {
        id: number;
    },
    {
        id: number;
        name: string;
        description: string;
        exp: bigint;
        created_at: Date;
        updated_at: Date | null;
        deleted_at: Date | null;
    }
>;

type UpdateCharacter = ProcedureDetails<
    {
        id: number;
        name: string;
        description: string;
        exp: bigint;
    },
    {
        id: number;
        updated_at: Date;
    }
>;

type DeleteCharacter = ProcedureDetails<
    {
        id: number;
        isHard: boolean;
    },
    {
        id: number;
        updated_at: Date;
    }
>;

type GetPowers = ProcedureDetails<
    {
        onlyDeleted: boolean;
        withDeleted: boolean;
    },
    {
        id: number;
        name: string;
    }
>;

type GetPower = ProcedureDetails<
    {
        id: number;
    },
    {
        id: number;
        name: string;
        description: string;
        price: bigint;
        created_at: Date;
        updated_at: Date | null;
        deleted_at: Date | null;
    }
>;

type UpdatePower = ProcedureDetails<
    {
        id: number;
        name: string;
        description: string;
        price: bigint;
    },
    {
        id: number;
        updated_at: Date;
    }
>;

type DeletePower = ProcedureDetails<
    {
        id: number;
        isHard: boolean;
    },
    {
        id: number;
        updated_at: Date;
    }
>;

type Procedure = {
    login: ProcedureDetails<
        {
            username: string;
            password: string;
        },
        {
            id: number;
            name: string;
            username: string;
            role: "player" | "admin";
        }
    >;
    register: ProcedureDetails<
        {
            name: string;
            email: string;
            gender: "Laki-laki" | "Perempuan";
            username: string;
            password: string;
            bio?: string;
        },
        {
            id: number;
            name: string;
            username: string;
            role: "player" | "admin";
            addedPlayerId: number;
        }
    >;
    get_users: GetUsers & { output: { role: "player" | "admin" } };
    get_admins: GetUsers;
    get_players: GetUsers;
    find_users: GetUsers & { input: { filter: string } };
    find_admins: GetUsers & { input: { filter: string } };
    find_players: GetUsers & { input: { filter: string } };
    get_admin_by_id: GetUser;
    get_player_by_id: GetUser;
    update_admin_by_id: UpdateUser;
    update_player_by_id: UpdateUser;
    delete_admin_by_id: DeleteUser;
    delete_player_by_id: DeleteUser;
    add_character: ProcedureDetails<
        {
            name: string;
            description: string;
            exp: bigint;
        },
        {
            addedCharacterId: number;
        }
    >;
    get_characters: GetCharacters;
    find_characters: GetCharacters & { input: { filter: string } };
    get_character_by_id: GetCharacter;
    update_character_by_id: UpdateCharacter;
    delete_character_by_id: DeleteCharacter;
    add_power: ProcedureDetails<
        {
            name: string;
            description: string;
            price: bigint;
        },
        {
            addedCharacterId: number;
        }
    >;
    get_powers: GetPowers;
    find_powers: GetPowers & { input: { filter: string } };
    get_power_by_id: GetPower;
    update_power_by_id: UpdatePower;
    delete_power_by_id: DeletePower;
    buy_power: ProcedureDetails<
        { playerId: number; powerId: number },
        { powerId: number }
    >;
    gacha_character: ProcedureDetails<
        { id: number },
        { id: number; name: string; description: string; exp: bigint }
    >;
    claim_character: ProcedureDetails<
        { id: number },
        { id: number; name: string; description: string; exp: bigint }
    >;
    sell_character: ProcedureDetails<
        { playerId: number; powerId: number },
        { id: number; name: string; description: string; exp: bigint }
    >;
    get_players_rank: ProcedureDetails<
        { type: "exp" | "money"; limit: number | undefined },
        { id: number; name: string; username: string; total_exp: bigint }
    >;
};

export type { ValuesOf, SqlError, Procedure };
