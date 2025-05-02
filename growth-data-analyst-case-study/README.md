# Growth Data Analyst Case Study

## Overview
This case study demonstrates analytics work for a business intelligence platform that serves e-commerce merchants. The analysis covers 2 critical areas: outbound campaign analysis with market sizing and marketing attribution modeling using SQL.

## Project Structure

This repository contains the following files:

1. **01_assignment.md**: The original case study requirements

2. **02_outbound.md**: Outbound marketing analysis including:
   - Campaign performance assessment using Pipeline Value per Company metric
   - Opportunity sizing across different market segments
   - Growth channel prioritization and recommendations

3. **03_attribution.md**:  SQL-based marketing attribution with:
   - Monthly order volume analysis by store
   - Touchpoint analysis showing multi-session purchase behavior
   - U-shaped attribution model implementation
   - Revenue attribution by marketing channel

4. **04_executive_summary.md**: High-level findings and strategic recommendations

5. **/sql_queries**: Directory containing SQL implementations:
   - `attribution_model.sql` - The U-shaped attribution model implementation
   - `monthly_orders.sql` - Analysis of order volumes over time
   - `touchpoints.sql` - Customer session and journey analysis

## Key Findings

### Outbound Marketing Analysis
- Identified top-performing outbound campaigns based on Pipeline Value per Company
- Developed a matrix-based campaign assessment framework balancing efficiency and scale
- Sized outbound opportunity to $589K-$1.15M in potential new ARR
- Recommended a balanced growth approach integrating outbound, inbound, and paid acquisition

### Attribution Analysis
- Implemented a U-shaped attribution model (40-20-40) based on multi-touch customer journeys
- Revealed that 56% of revenue is attributed to direct traffic, followed by organic Google (10%)
- Created a session-based approach to handle sessionId inconsistencies in the data

## Methodology Notes

- Used a 30-minute inactivity threshold for session boundaries (industry standard)
- Implemented IP-based user identification with a 30-day lookback window
- Applied revenue normalization to ensure attribution weights sum to exactly 1.0 
- Created custom session logic due to inconsistencies in the provided sessionId field

## Skills Demonstrated

This case study showcases expertise in:

- **Growth Strategy**: Analysis of outbound campaign performance and scaling opportunities
- **Market Sizing**: TAM analysis and revenue potential calculation
- **Multi-channel Marketing**: Assessment of different acquisition channels
- **SQL Data Analysis**: Complex attribution modeling with BigQuery
- **Customer Journey Analysis**: Session-based user behavior tracking
- **Marketing Analytics**: Channel effectiveness and ROI measurement

## Interactive Presentation

This case study was presented as an interactive data application using [Evidence.dev](https://evidence.dev), a lightweight framework for building data products with SQL.

For this project, Evidence.dev provided several key advantages:
- **Code-first approach**: Enabled version control and easy collaboration
- **SQL-driven analysis**: Allowed direct implementation of complex attribution models
- **Interactive components**: Created dynamic filtering for marketing channel exploration
- **Publication-quality visualizations**: Generated clear charts for presenting results
- **Fast loading**: Pre-built queries ensured stakeholders didn't have to wait for data

The interactive format enabled a more engaging presentation of the analysis, allowing stakeholders to explore the data and findings dynamically rather than through static reports.

*Note: This case study has been anonymized to protect company-specific information while preserving the analytical approach and methodologies used.*