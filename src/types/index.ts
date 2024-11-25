type User = {
    username: string;
    password: string;
};

type RegisterUser = {
    name: string;
    email: string;
    gender: string;
    username: string;
    password: string;
    profilePicture?: string;
    bio?: string;
};

export type { User, RegisterUser };
