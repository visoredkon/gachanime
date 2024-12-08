declare module "bun" {
    interface Env {
        BUN_ENV: string;

        MYSQL_HOST: string;
        MYSQL_USER: string;
        MYSQL_PASSWORD: string;
        MYSQL_DATABASE: string;

        MIGRATE_MYSQL_HOST: string;
        MIGRATE_MYSQL_USER: string;
        MIGRATE_MYSQL_PASSWORD: string;

        PORT: string;
        JWT_SECRET_KEY: string;
    }
}
