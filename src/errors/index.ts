const skillIssueError = "Skill issue [unhandled exception]";

export class SkillIssueError extends Error {
    constructor(message?: string) {
        if (message) {
            super(`${skillIssueError}: ${message}`);

            return;
        }

        super(skillIssueError);
    }
}
