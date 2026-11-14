# 🯇 Natural Selection Development Process Document 🯈

## Repository Architecture
[Godot Standard File Structure Organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html#organization)

Two of the most common Godot project structure both organize file structure by grouped 

```text
Natural-Selection-Game/
├── addons/
│   └── GdUnit4/
├── entities/
│   ├── characters/
│   └── enemies/
├── levels/
├── systems/
│   └── combat/
├── scripts/
│   ├── models/
│   └── gloabal/
├── tests/
├── reports/
├── .github/
│   └── workflows/
│       └── gdunit4-tests.yml
├── .gitignore
├── project.godot
├── icon.svg
├── .editorconfig
├── .gitattributes
└── README.md
```

## Branching/Workflow Model

### Developing On a Branch

The branching model for this repository is GitHub Flow:

>**Issue -> Branch From Main -> Commit and Push Changes -> Pull Request -> Two Code Review Approvals -> Merge Into Main -> Delete Branch**

To develop a fix, feature, or release an issue must be created. Branches of main are made to address an issue. Once a branch's development is complete, a pull reuest is made to merge the branch into main. One other contributer must review and approve the pull request before the merge into main can be completed. After the branch is merged into main, it is deleted.

### Branch Naming Convention

Branches will all the convention branch-type/branch-name. Branches will be all lower case and use dashes to represent spaces.

#### Bugfix or Functionality Correction Branch

>fix/branch-name

#### New Feature or Functionality Alteration Branch

>feature/branch-name

#### Release Version Branch

>release/branch-name
