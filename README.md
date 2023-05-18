# Music Show Management System

The Music Show Management System is a web application built using Oracle Database and Express.js for the backend API. It provides a comprehensive solution for managing music shows, including artists, venues, show schedules, and ticket sales.

## Features

- **Artist Management**: Create, update, and delete artists. Retrieve artist information by ID.
- **Venue Management**: Create, update, and delete venues. Retrieve venue information by ID.
- **Show Management**: Create, update, and delete shows. Retrieve show information by ID.
- **Show Scheduling**: Schedule shows at specific venues. Assign artists and set show dates and times.
- **Ticket Sales**: Sell tickets for shows. Track ticket availability and generate reports on ticket sales.
- **Revenue Tracking**: Generate reports on ticket sales and revenue generated from shows.
- **Authentication and Authorization**: Secure access to the system with authentication and enforce authorization for different user roles.

## Prerequisites

Before running the Music Show Management System, ensure you have the following prerequisites:

- Node.js installed on your machine
- Oracle Database installed and configured
- Oracle Database Client for development purposes

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/dpquoc/R-E-O.git

2. Navigate to the project directory:
3. Install dependencies:
```
npm install
```

## Configuration
1. Create a .env file ( if it doesn't exist ) in the project root directory.
2. Configure the environment variables in the .env file:
```
ORACLE_USER = your_oracle_database_username
ORACLE_PASSWORD = your_oracle_database_password
ORACLE_URI = your_oracle_database_connection_string
```
Replace `your_oracle_database_username`, `your_oracle_database_password`, and `your_oracle_database_connection_string` with your actual Oracle Database credentials and connection string.

## Usage
1. Start server
```
npm start
```
2. The Music Show Management System API will be available at `http://localhost:3000`.
