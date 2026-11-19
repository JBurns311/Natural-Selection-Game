# 🯇 Natural Selection Development Process Document 🯈

## Repository Architecture
[Godot Standard File Structure Organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html#organization)

[Reference on Alternative Godot File Structure](https://youtu.be/s6Nx-9hRFyk?si=IocAtJTjWZDy3jT7)

Two of the most common Godot project structures both organize file structure by groups. The first organizes projects by file types. For instance, scripts in one folder, game scenes in another folder, and game assets in another folder. This organizational structure unfortunately has issues scaling into larger projects like ours. When you have tens of scenes, it can be difficult to find that one script or asset that you need to link to this scene. The second common organizational structure sorts files by purpose. This scheme puts all of the related files for one entity, level, system, etc into a single folder. This allows for easier searching by related files. The downside is file structure bloat. However, we believe that better contextual organization is worth this trade-off.

>**We follow Godot's convention of snake_case files and PascalCase node/scene names.**


```text
Natural-Selection-Game/
├── addons/
│   ├── ai_algorithms/
│   └── gdUnit4/
├── entities/
│   ├── characters/
│   └── enemies/
├── levels/
├── systems/
│   └── combat/
├── scripts/
│   ├── models/
│   └── global/
├── tests/
│   ├── unit/
│   └── integration/
├── docs/
│   ├── Semester_1/
│   ├── Semester_2/
│   └── development_process.md
├── README.md
├── project.godot
├── icon.svg
├── .gitignore
├── .editorconfig
├── .gitattributes
└── .github/
    └── workflows/
        └── gdunit4-tests.yml
```

- addons: This folder contains all external plugins we will use for the project. Individual plugins may not follow our file naming conventions as they are external to our project.
- entities: This folder contains entity game scenes and their related scripts and assets. Entities include dynamically movable objects in the game such as the player, enemies, and moving platforms.
- levels: This folder contains all game levels and their related scripts and assets. Levels generally contain tile maps as well as a method of spawning entities in the level.
- systems: This folder contains all overall game systems that are used in other entities or levels. An example of a game system would be the combat system that is used by several different entities.
- scripts: This folder contains all tooling, global, or abstract scripts that are used in other parts of the project.
- tests: This folder contains all of our written unit and integration tests for various parts of the game. The test suites are written using API calls to GdUnit4.
- docs: This folder contains project documentation.
- .github: This folder contains GitHub related workflows, such as our GitHub Action to verify that all test suites passed on a push or pull request.

## Branching/Workflow Model

### Main Branches

The only main branch for this repository is main. All other branches are temporary development branches.

### Developing On a Branch

The branching model for this repository is GitHub Flow:

>**Issue -> Branch From Main -> Commit and Push Changes -> Pull Request -> Two Code Review Approvals -> Merge Into Main -> Delete Branch**

### Branch Naming Convention

Branches will all follow the convention branch-type/branch-name. Branches will be all lowercase and use dashes to represent spaces.

#### Bugfix or Functionality Correction Branch

>fix/branch-name

#### New Feature or Functionality Alteration Branch

>feature/branch-name

#### Release Version Branch

>release/branch-name

## Code Development & Review Policy

To develop a fix, feature, or release branch, a GitHub issue must first be created. Branches of main are made to address an issue. Our CI pipeline runs every test suite in our tests folder. The CI pipeline is run every time a commit is pushed upstream to the GitHub repository. Once a branch's development is complete, a pull request must be made to merge the branch into main. The entire CI pipeline check must pass before the pull request can be completed. One other contributor must review and approve the pull request before the merge into main can be completed. After the branch is merged into main, it must be deleted to keep the number of active branches low.

