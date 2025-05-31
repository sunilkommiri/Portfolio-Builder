# Portfolio Builder Web App

This project is a Portfolio Builder web application allowing users to create, manage, and showcase their professional achievements, skills, projects, and experience.

## Project Structure

-   `/frontend`: React.js single-page application for the user interface.
-   `/backend`: Node.js (Express.js) application serving as the API and handling business logic.
-   `/terraform`: Terraform configurations for provisioning AWS infrastructure.
-   `Jenkinsfile`: CI/CD pipeline definition for Jenkins.
-   `docker-compose.yml`: For local development environment setup.

## Prerequisites

-   Node.js (v18.x or later recommended)
-   npm or yarn
-   Docker & Docker Compose
-   Terraform (v1.x recommended)
-   AWS CLI configured (or EC2 instance profile with necessary permissions for Jenkins)
-   Git

## Local Development Setup

1.  **Clone the repository:**
    ```bash
    git clone YOUR_GIT_REPOSITORY_URL
    cd portfolio-builder-app
    ```

2.  **Configure Environment Variables:**
    * Copy `.env.example` files in `frontend/` and `backend/` (if they exist) to `.env` and fill in the necessary values for local development (e.g., local database connection strings, API keys for local testing).
    * For the backend, you'll need a local PostgreSQL instance running.

3.  **Using Docker Compose (Recommended for local):**
    * Ensure Docker is running.
    * From the root directory:
        ```bash
        docker-compose up --build
        ```
    * This will typically build and run:
        * Frontend React app (e.g., on `http://localhost:3000`)
        * Backend Node.js API (e.g., on `http://localhost:3001`)
        * PostgreSQL database (e.g., on port `5432`)

4.  **Manual Local Setup (Alternative):**
    * **Backend:**
        ```bash
        cd backend
        npm install # or yarn install
        # Set up your .env file with DB_USER, DB_HOST, DB_DATABASE, DB_PASSWORD, DB_PORT
        npm run dev # or your script to start the dev server
        ```
    * **Frontend:**
        ```bash
        cd frontend
        npm install # or yarn install
        # Set up your .env file if needed (e.g., REACT_APP_API_URL=http://localhost:3001/api)
        npm start # or yarn start
        ```

## Building for Production (Done by Jenkins CI/CD)

The `Jenkinsfile` handles the build process for production, which includes:
1.  Building Docker images for the frontend and backend.
2.  Pushing these images to AWS ECR.

## Deployment (Handled by Jenkins CI/CD via Terraform & ECS)

-   **Infrastructure:** Defined in the `/terraform` directory and applied by Jenkins (or manually initially). This sets up VPC, ECR, RDS, ECS, ALB, etc.
-   **Application:** Jenkins updates ECS services to deploy the new Docker images.

## Terraform Usage

Located in the `/terraform` directory.
1.  `cd terraform`
2.  `terraform init` (run once, or if providers change)
3.  `terraform plan` (to see changes)
4.  `terraform apply` (to apply changes - be cautious!)
Ensure your AWS credentials are set up or you are running this from an environment with appropriate IAM roles. The S3 backend for Terraform state should be configured in `terraform/backend.tf`.

## Available Scripts (Examples)

**Frontend (`frontend/package.json`):**
-   `npm start` / `yarn start`: Runs the app in development mode.
-   `npm run build` / `yarn build`: Builds the app for production.

**Backend (`backend/package.json`):**
-   `npm run dev` / `yarn dev`: Starts the backend server in development mode (e.g., with nodemon).
-   `npm start` / `yarn start`: Starts the backend server for production.
-   `npm run db:migrate` / `yarn db:migrate`: Runs database migrations (if configured).

## API Endpoints (To be defined)

-   `POST /api/auth/register`
-   `POST /api/auth/login`
-   `GET /api/portfolio/:userId`
-   `PUT /api/portfolio/:userId`
-   ...etc.

---
