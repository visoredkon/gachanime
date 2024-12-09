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
        onlyDeleted?: boolean;
        withDeleted?: boolean;
    },
    {
        id: number;
        name: string;
        username: string;
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
            profilePicture?: string;
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
};

export type { ValuesOf, SqlError, Procedure };
