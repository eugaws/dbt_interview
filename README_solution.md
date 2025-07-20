# Solution to the Test Assignment: dbt + DuckDB + Salesforce

## Project Description

This project is an analytical data mart based on dbt and DuckDB using sample Salesforce data. The goal is to demonstrate skills in building staging, dimension, and fact models, testing, ensuring data quality, and automating CI/CD.

---

## Project Structure

- **transformation/models/staging/** — staging models (raw data from Salesforce)
- **transformation/models/dimensions/** — dimension models (dimensions: accounts, contacts, users, products, cases, etc.)
- **transformation/models/facts/** — fact models (facts: opportunity history, lead conversions, case resolution, etc.)
- **transformation/snapshots/** — snapshot models for tracking changes (e.g., for accounts)
- **transformation/tests/** — custom and data quality tests
- **.github/workflows/dbt.yml** — CI/CD pipeline for automatic code and model checks
- **.sqlfluff** — configuration for SQLFluff (SQL linter)
- **requirements.txt** — all Python dependencies for reproducible environment

---

## Main Steps

### 1. Staging Data Analysis
- All staging models were explored (e.g., stg_salesforce__opportunity, stg_salesforce__lead, stg_salesforce__case, stg_salesforce__account, stg_salesforce__contact, stg_salesforce__campaign, etc.).
- Key entities and relationships between them were identified.

### 2. Building Dimension Models
- Dimensions for main entities were created:
  - **dim_accounts** — companies/organizations
  - **dim_contacts** — individuals
  - **dim_users** — Salesforce users
  - **dim_products** — products
  - **dim_cases** — support cases
  - **dim_campaigns** — marketing campaigns
  - **dim_date** — calendar dimension
- All dimensions use surrogate keys (`*_key`), have descriptions, and are tested for uniqueness and not_null.

### 3. Building Fact Models
- Main fact tables implemented:
  - **fct_opportunity_history** — opportunity change history: tracks all changes in opportunity stage, amount, close date, probability, with change type flags, deltas, and stage progression indicators.
  - **fct_lead_conversions** — lead conversion facts: includes conversion velocity, detection method, and one-hot encoded categorical features.
  - **fct_case_resolution** — case resolution facts: includes resolution speed, SLA performance, quality, and one-hot encoded categorical features.
  - **fct_case_history** — case history: tracks all case events with one-hot encoding for event types.
  - **fct_campaign_effectiveness** — marketing campaign effectiveness: includes cost, response, lead, conversion, ROI metrics, and one-hot encoding for campaign type and status.
  - **fct_solution_usage** — knowledge base solution usage: includes usage metrics, publication/review flags, and format indicators.
- Fact tables have foreign key relationships to dimensions, metrics, flags, and business logic.

### 4. Model Testing
- dbt tests are configured for all models:
  - `unique`, `not_null` for keys
  - `relationships` for foreign keys
  - Range checks for metrics (e.g., amounts, probabilities, dates)
  - Custom data quality tests (e.g., case closed date not before created date)
- All tests pass successfully (`dbt test`).

### 5. Documentation
- Descriptions for all models and key fields are added in schema.yml.
- The README describes the structure, logic, and run instructions.

### 6. Linting and Style
- SQLFluff is used with configuration for DuckDB and dbt (`sqlfluff.toml`).
- Style rules, indentation, capitalization, aliasing, etc. are enforced.
- Linting runs automatically in CI/CD.

### 7. CI/CD
- GitHub Actions workflow (`.github/workflows/dbt.yml`) is set up:
  - Install dependencies
  - SQLFluff linting
  - dbt deps, compile, run, test
- The pipeline runs on push and pull request to `main` and `dev` branches.

### 8. Snapshots
- A snapshot for dim_accounts (snapshots/snap_dim_accounts.sql) is implemented to track changes in key business fields.

---

## Python Environment

- All dependencies are listed in `requirements.txt`.
- The recommended way is to use a virtual environment.


---

## How to Run the Project

1. Clone the repository
2. Create and activate a virtual environment:
   ```bash
   python3 -m venv dbt_v
   source dbt_v/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Check or create `profiles.yml` for dbt (see example in `transformation/profiles.yml`)
5. Run dbt and lint:
   ```bash
   dbt deps
   dbt run
   dbt test
   sqlfluff lint transformation/models/ --config sqlfluff.toml
   ```
6. For CI/CD — just push or create a pull request to the `dev` or `main` branch


---

## Implementation Features and Best Practices
- Clear folder structure and model naming
- Use of surrogate keys and foreign keys
- Maximum test coverage
- Documentation for models and fields
- One-hot encoding for categorical features in fact tables
- Linting and automation via CI/CD
- Only real data quality warnings remain; all technical/test errors are fixed

---

## Adding Custom Tests
- Place custom tests in `transformation/tests/`.
- Example: `test_fct_solution_usage_custom.sql` checks that all `times_used` values are non-negative.
- Use dbt's Jinja templating and SQL to create any logic you need.

---

## Contacts
If you have any questions about the solution — feel free to ask! 