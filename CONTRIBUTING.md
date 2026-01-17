# Contributing to PromSNMP Metrics

Thank you for your interest in contributing to PromSNMP Metrics! We welcome contributions from the community to help improve this project.

## Getting Started

1.  **Fork the repository** on GitHub.
2.  **Clone your fork** locally:
    ```bash
    git clone https://github.com/your-username/promsnmp-metrics.git
    cd promsnmp-metrics
    ```
3.  **Ensure prerequisites** are installed:
    *   Java 21 (or compatible JDK)
    *   Maven (wrapper provided)
    *   Docker (for container builds and integration testing)

## Building the Project

We use `make` to simplify common build tasks.

*   **Build the application:**
    ```bash
    make
    ```
    This compiles the code and runs tests.

*   **Build the Docker image:**
    ```bash
    make oci
    ```

## Development Workflow

1.  Create a new branch for your feature or fix:
    ```bash
    git checkout -b feature/my-new-feature
    ```
2.  Make your changes. Please adhere to the existing code style (Spring Boot/Java conventions).
3.  Add tests for any new functionality.
4.  Run tests locally to ensure no regressions:
    ```bash
    make tests
    ```
5.  Commit your changes with clear, descriptive messages.

## Submitting a Pull Request

1.  Push your branch to your fork.
2.  Open a Pull Request (PR) against the `main` branch of the upstream repository.
3.  Provide a clear title and description of your changes.
4.  Wait for review and address any feedback.

## Reporting Issues

If you find a bug or have a feature request, please open an issue on the GitHub repository. Provide as much detail as possible, including steps to reproduce the issue.
