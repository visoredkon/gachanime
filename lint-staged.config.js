export default {
    "*.{ts,tsx,json}": (stagedFiles) => {
        return [
            `biome lint --write --error-on-warnings ${stagedFiles.join(" ")}`,
            `biome format --write ${stagedFiles.join(" ")}`,
        ];
    },
    "**/*.ts?(x)": () => "tsc --project tsconfig.json",
};
