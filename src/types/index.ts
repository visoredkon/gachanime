type SqlError = { sqlState: number } & Error;

// === Start Request Type ===
type ReqLoginUser = {
    username: string;
    password: string;
};

type ReqRegisterUser = {
    name: string;
    email: string;
    gender: "Laki-laki" | "Perempuan";
    username: string;
    password: string;
    profilePicture?: string;
    bio?: string;
};
// === End Request Type ===

// === Start Response Type ===
type ResRegisterUser = Record<"addedPlayerId", number>;
// === End Response Type ===

export type { SqlError, ReqLoginUser, ReqRegisterUser, ResRegisterUser };
