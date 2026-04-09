# Automated DevSecOps Pipeline on AWS

This project demonstrates the implementation of a fully automated CI/CD/CD pipeline for a Java/Spring Boot application (Mini-ERP) using **Infrastructure as Code (IaC)** and integrated security testing. The project focuses on architecting a secure, traceable, and reliable deployment lifecycle on AWS.

## Architecture & Stack

The infrastructure is provisioned via **Terraform** and consists of:

* **Compute:** AWS Fargate (ECS) for serverless container orchestration.
* **Database:** Amazon RDS (PostgreSQL).
* **CI/CD Orchestration:** AWS CodePipeline.
* **Build & Security:** AWS CodeBuild.
* **Monitoring & Observability:** Datadog APM integration.

## DevSecOps Integration

Security was treated as a fundamental part of the pipeline (Shift-Left approach):

1.  **SAST (Static Application Security Testing):** Integrated **SonarQube** during the Build phase to analyze code quality and identify vulnerabilities in the source code.
2.  **DAST (Dynamic Application Security Testing):** Integrated **OWASP ZAP** to scan the running application for runtime vulnerabilities.

## Pipeline Lifecycle

1.  **Source:** Automatic trigger via GitHub Webhooks (using CodeStar Connections).
2.  **Build:** * Artifact compilation and Docker image creation.
    * Execution of **SonarQube** security scans.
    * Docker image push to **Amazon ECR**.
3.  **Deploy:** * Automated update of the **ECS Service**.
    * Blue/Green style deployment logic via **Fargate** task revisions.
4.  **Monitor:** * Real-time logging and performance metrics via **CloudWatch** and **Datadog Agent**.
