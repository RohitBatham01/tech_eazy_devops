# 🚀 TechEazy DevOps Assignment – Automate EC2 Deployment with Terraform

This project automates the deployment of a Spring Boot application on AWS EC2 using Terraform.  
It provisions an EC2 instance, installs dependencies, clones the app repo, builds it, runs it on port **80**, and schedules an **auto-shutdown** to save costs.  

---

## 📌 Features
- Creates an **EC2 instance** in AWS Free Tier (default: `t2.micro`).
- Installs **Java 21, Maven, Git**.
- Clones the GitHub repo:  
  👉 [TechEazy Test Repo](https://github.com/Trainings-TechEazy/test-repo-for-devops)
- Builds the app using:
  ```bash
  mvn clean package -DskipTests

