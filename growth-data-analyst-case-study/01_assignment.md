# Senior Growth Data Analyst Case Study Assignment

## Overview
This case study focuses on data analysis for a growth team at a business intelligence tool for e-commerce merchants. It has 2 main parts: outbound opportunity sizing and marketing attribution analysis.

## Part 1: Outbound Sizing

### Context
In 2024, the company ran multiple outbound campaigns across different market segments, generating conversion performance data.

The goal is to analyze this performance and estimate the New ARR (Annual Recurring Revenue) potential if this approach is scaled to the whole addressable market.

### Tasks
Using historical performance and market data, please:

1. **Assess outbound effectiveness**
   - How would you assess outbound performance?
   - Which metric would be your North star?
   - Which campaigns are the top performers according to you?

2. **Size the outbound opportunity**
   - Estimate the potential New ARR generated from scaling outbound efforts to the TAM (i.e. Shopify brands with > $1M GMV)

3. **Prioritize outbound as a growth lever**
   - How does this compare to other acquisition channels like Inbound or Ads?
   - With equivalent performance, would you focus on scaling Outbound?
   - What bottlenecks or constraints could impact scaling outbound?
   - The goal is to understand how you'd structure a scalable acquisition mix by weighing the tradeoffs between outbound, inbound, and paid channels.

4. **Recommend next steps**
   - What would you optimize or test next?

### Resources Provided
- Series A Deck
- Past campaigns data (CSV)
- Market Data

## Part 2: Data Exercise - Attribution

### Context
To optimize their paid marketing efforts, brands need to understand where their orders are coming from. The company recently built a tracking pixel and installed it on the  websites of some customers.

This pixel tracks all events happening on the website and automatically parses the UTM tags (utmSource, utmMedium, and utmCampaign) of the URL that user lands on. If there are no UTM tags, it is most probably a user coming from a direct source.

### Goals
1. **Calculate the number of orders per month per store**

2. **Build a simple attribution model:**
   - Choose the most relevant model for this particular use case, and justify why
   - Build it by attributing every OrderId to the right touchpoint(s)
   - You can build the customer journey by joining on the IP address and Timestamp
   - If there is no utmSource, you can use the pageReferrer

*Note: This case study has been anonymized to protect company-specific information while preserving the analytical approach required.*