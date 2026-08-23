# Healthcare Claims & Operations Analytics

An end-to-end healthcare analytics project built with PostgreSQL, SQL, Power BI, Power Query, and DAX using synthetic Synthea healthcare data.

The project transforms raw healthcare data into a structured analytics model and an interactive three-page Power BI dashboard focused on claims cost, member utilization, provider performance, payer trends, conditions, and healthcare services.

## Project Overview

This project simulates a healthcare payer and operations analytics workflow. Raw synthetic healthcare data was loaded into PostgreSQL, cleaned and transformed through staging tables, modeled into an analytics-ready star schema, and summarized through reusable business views.

The final Power BI report analyzes the 2021–2025 reporting period across three areas:

- Executive claims and cost performance
- Provider and utilization analysis
- Clinical conditions and service drivers

## Tools & Technologies

- PostgreSQL
- SQL
- Power BI
- Power Query
- DAX
- Data modeling
- Git & GitHub
- Synthea synthetic healthcare data

## Data Pipeline

`Synthea CSV Data → PostgreSQL Raw Layer → Staging Layer → Analytics Star Schema → Business Views → Power BI Dashboard`
