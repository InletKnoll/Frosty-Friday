# Frosty Friday Challenge Solutions

This repository contains my personal solutions to the weekly [Frosty Friday](https://frostyfriday.org/) data challenges. Each week presents a new data-related puzzle that needs to be solved using Snowflake and its ecosystem.

## Technology Stack

The solutions in this repository primarily use the following technologies:

- **Snowflake**: The core cloud data platform for all challenges.
- **SQL**: Standard SQL for data manipulation, transformation, and setup within Snowflake.
- **Python**: For more complex logic and building data applications.
- **Snowpark**: The Snowflake library for Python to query and process data in Snowflake without moving it.
- **Streamlit**: A Python library to create and share custom web apps for machine learning and data science.

## Repository Structure

The repository is organized by week. Each weekly challenge and its corresponding solution are contained within a directory named `week<NNN>`, where `<NNN>` is the week number of the challenge.

```
.
├── init.sql              # Initial database setup script
├── week002/
│   └── week2.sql         # Solution for Week 2
├── week008/
│   ├── week8.py          # Streamlit app for Week 8
│   └── week8.sql         # Data setup for Week 8
└── ...                   # And so on for other weeks
```

## Usage

The files in this repository are meant to be examples of how to solve the Frosty Friday challenges.

### SQL Scripts

The `.sql` files can be executed within a Snowflake worksheet. You will need to have a Snowflake account and the necessary permissions to create databases, schemas, tables, and other objects. The `init.sql` script can be used for initial role and database setup.

### Python Applications

The `.py` files are typically Streamlit applications that connect to Snowflake using Snowpark. To run them, you will need to:

1.  **Install dependencies**:
    ```bash
    pip install streamlit snowflake-snowpark-python python-dotenv
    ```

2.  **Set up Snowflake Connection**: The applications often use environment variables to connect to Snowflake. You will need to create a `.env` file or set the following environment variables with your Snowflake account details:
    - `SNOWFLAKE_ACCOUNT`
    - `SNOWFLAKE_USER`
    - `SNOWFLAKE_PASSWORD`
    - `SNOWFLAKE_ROLE`

3.  **Run the app**:
    ```bash
    streamlit run path/to/your_app.py
    ```

## Note on Language

Please note that most of the code comments and some in-code text are written in **Japanese**.
