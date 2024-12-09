type ValuesOf<T> = T[keyof T][];

interface SqlError extends Error {
    sqlState: number;
}

type ProcedureDetails<Input, Output> = {
    input: Input;
    output: Output;
};

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
    get_admins: ProcedureDetails<
        {
            onlyDeleted?: boolean;
            withDeleted?: boolean;
        },
        {
            id: number;
            name: string;
            email: string;
            username: string;
        }
    >;
    get_players: ProcedureDetails<
        {
            onlyDeleted?: boolean;
            withDeleted?: boolean;
        },
        {
            id: number;
            name: string;
            email: string;
            username: string;
        }
    >;
};

export type { ValuesOf, SqlError, Procedure };
