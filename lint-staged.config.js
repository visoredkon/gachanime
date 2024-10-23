export default {
    "*.{ts,tsx,json}": (stagedFiles) => {
        return [
            `biome lint --write ${stagedFiles.join(" ")} --error-on-warnings`,
            `biome format --write ${stagedFiles.join(" ")}`,
        ];
    },
    "**/*.ts?(x)": () => "tsc --project tsconfig.json",
};
