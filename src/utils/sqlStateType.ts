import { SkillIssueError } from "@/errors";

export const sqlStateType = (
    code: number,
): "Warning" | "Defined Exception" | "Exception" | "No data" | never => {
    if (code <= 1000) {
        return "Warning";
    }

    if (code >= 45000) {
        return "Defined Exception";
    }

    if (code >= 30000) {
        return "Exception";
    }

    if (code >= 20000) {
        return "No data";
    }

    throw new SkillIssueError();
};
