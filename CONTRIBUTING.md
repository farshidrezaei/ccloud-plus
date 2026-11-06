# Contributing to CCloud+ (CCloud Plus)

We love contributions! Whether you are fixing bugs, improving documentation, submitting feature ideas, or adding new capabilities, your help makes CCloud+ better for everyone.

---

## 🛠️ Code of Conduct & Principles

- **Be Respectful**: Treat everyone in the community with dignity and respect.
- **Respect the Foundation**: CCloud+ evolved from [CCloud-GUI](https://github.com/code3-dev/CCloud-GUI). Upstream credits and respect for original authors must always be preserved.
- **Keep Quality High**: Ensure all code passes `flutter analyze --fatal-infos` and `dart format`.

---

## 🚀 How to Contribute

### 1. Reporting Bugs
- Search existing issues to ensure the bug hasn't been reported.
- Open an issue using the Bug Report template.
- Include your operating system (Linux distro, Windows version, macOS version), steps to reproduce, and any error logs.

### 2. Suggesting Enhancements
- Open a feature request issue.
- Describe the motivation, use case, and proposed UX or design.

### 3. Submitting Code Changes

1. **Fork the Repository**:
   Click Fork on [github.com/farshidrezaei/ccloud-plus-desktop](https://github.com/farshidrezaei/ccloud-plus-desktop).

2. **Create a Topic Branch**:
   ```bash
   git checkout -b feature/my-cool-feature
   # or
   git checkout -b fix/issue-description
   ```

3. **Coding Standards**:
   - Write clean, null-safe Dart code.
   - Run linter and formatting before committing:
     ```bash
     dart format .
     flutter analyze --fatal-infos
     ```

4. **Commit Guidelines**:
   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat: Add new audio visualizer`
   - `fix: Resolve audio track switching latency`
   - `docs: Update Linux installation guide`

5. **Submit a Pull Request**:
   - Push your branch to your fork.
   - Open a Pull Request targeting `main`.
   - Complete the PR template checklist.

Thank you for contributing to the open-source media ecosystem! ❤️
