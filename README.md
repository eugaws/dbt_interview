# SQL Test dbt Project

Welcome to the sql test repository! This project is based on the [dbt](https://www.getdbt.com/) and uses an embedded [DuckDB](https://duckdb.org/) database with sample Salesforce data.

The goal of this test is to evaluate your understanding of SQL, dbt, and dimensional data modeling concepts.

## Instructions

- **Create a public git hub repository**
- **Commit this folder contents**
- **Set Up dbt**
- **Explore Staging Models**
- **Build Dimension & Fact Models**:  
   Based on the relevant staging models, create the following:
   - **Dimension Models**: Identify and create necessary dimension tables. These can be date dimensions, user dimensions, product dimensions, etc. depending on the staging data provided.
   - **Fact Models**: Build out the fact tables that centralize the measures and keys.
   
   Ensure your models are placed in the appropriate directories (e.g., `models/dimensions/` and `models/facts/`).

- **Test Your Models**:  
   Use dbt's testing functionality to ensure the integrity of your models. Ensure that relationships are correctly established, and there are no data anomalies.
   ```bash
   dbt run
   dbt test
   ```

- **Commit Your Changes**
- **Submit Your Test**:  
   Notify the hiring team by submitting the link to your repository.

## Evaluation

Your submission will be evaluated based on:

- Correctness of the models.
- Efficiency and simplicity of the SQL written.
- Adherence to dbt best practices.
- Robustness of tests and validations.

Best of luck, and we look forward to reviewing your models!
