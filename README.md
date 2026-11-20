
# Olist E-commerce Analytics Engineering

An end-to-end analytics engineering project using the Brazilian Olist e-commerce dataset to transform raw transactional data into analytics-ready models and interactive business intelligence dashboards.

## Project Overview

This project demonstrates a modern analytics workflow, covering data ingestion, transformation, data quality testing, documentation, continuous integration, and business intelligence.

## Technology Stack

- Python — Data ingestion and Power BI exports
- DuckDB — Analytical database
- dbt Core — SQL transformations, testing, and documentation
- Power BI — Interactive dashboards and DAX measures
- GitHub Actions — Automated CI validation
- Git and GitHub — Version control

## Data Architecture

Raw Olist CSV Files
        |
        v
Python Data Ingestion
        |
        v
DuckDB Raw Tables
        |
        v
dbt Staging Models
        |
        v
dbt Intermediate Models
        |
        v
dbt Analytics Marts
        |
        v
Python CSV Exports
        |
        v
Power BI Dashboards

## Data Models

### Staging
Standardised source data with consistent column types and naming.

### Intermediate
Reusable business transformations including order-item enrichment and order aggregation.

### Analytics Marts
- dim_customers
- dim_products
- fct_orders
- mart_monthly_revenue

## Data Quality and CI

The project implements:

- dbt generic tests
- Custom SQL data quality tests
- Revenue reconciliation checks
- Delivery date validation
- Incremental fact table processing
- Automated GitHub Actions CI
- dbt model documentation and lineage

## Power BI Dashboard

The report contains four analytical pages:

1. Executive Overview — Revenue, orders, AOV, and sales trends
2. Product Analytics — Product categories, revenue contribution, and units sold
3. Customer Analytics — Repeat customers, lifetime value, and customer behaviour
4. Delivery & Logistics — Delivery performance, delays, and operational KPIs

## Running the Project

Install the project dependencies and configure the dbt DuckDB profile.

Load the Olist source data into DuckDB using the project's ingestion workflow.

Run the dbt transformations:

```bash
dbt run
```

Execute data quality tests:

```bash
dbt test
```

Generate documentation:

```bash
dbt docs generate
dbt docs serve
```

Export analytics-ready datasets:

```bash
python scripts/export_to_powerbi.py
```

Open the Power BI report and refresh the imported data.

## Business Value

The project enables analysis of revenue performance, product demand, customer retention, and delivery efficiency through tested, reusable analytical datasets.

## Future Improvements

- Automated dashboard data refresh
- Cloud-based analytical data storage
- Additional customer segmentation models
- Advanced cohort and retention analysis
