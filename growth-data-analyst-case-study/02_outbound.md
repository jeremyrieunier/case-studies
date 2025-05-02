# Assessing Outbound Effectiveness
The growth team at [Redacted] is responsible for lead generation, with the sales team handling conversion of these opportunities into customers. Thus, the goals of these outbound campaigns are:

1. Generate qualified pipeline opportunities for the sales team to work on
2. Engage ICP companies with relevant messaging

## Primary KPI Recommendation
Given these goals, the ideal Top KPI for the outbound campaigns is **Pipeline Value per Company Touched** because it:

- Directly measures how efficiently outbound efforts generate pipeline value
- Aligns with the growth team's primary goal of creating opportunities for the sales team while keeping it accountable
- Accounts for both the quality and quantity of outreach

This metric is calculated as follows:
> Pipeline Value Created / Companies Touched

![Pipeline Value Per Company](images/pipeline_value_company.png)

## Supporting Metrics
While Pipeline Value per Company Touched is the primary metric, I recommend tracking these supporting metrics to provide additional context:

### Pipeline Revenue Win Rate
While the growth team does not own this metric, it measures how effectively the sales team converts pipeline opportunities into actual revenue. It highlights alignment between growth and sales teams and identifies which types of opportunities close at a higher rate.

This metric is calculated as follows:
> ARR Value Created / Pipeline Value Created


### ARR Value per Company Touched
This metric shows the complete business impact of outbound efforts, capturing both pipeline generation efficiency and sales conversion effectiveness.

This metric is calculated as follows:
> ARR Value Created / Companies Touched


### ICP Targeting Accuracy
This metric measures how well campaigns focus on the Ideal Customer Profile (ICP).

This metric is calculated as follows:
> (ICP Companies Touched / Companies Touched) × 100%


# Top Performing Campaigns
To properly evaluate campaign performance, we must consider both efficiency (Pipeline Value per Company Touched), scale (number of companies touched), and impact (total pipeline generated) using a matrix bubble chart:
![Top performing campaigns](images/matrix.png)
*Note: The above picture is from an interactive chart*

## Best Overall Performers
These campaigns generate a substantial pipeline with good efficiency, striking a balance between reach and performance.

| Campaign | Companies Touched | Pipeline Value Created | Pipeline Value Per Company | Arr Value Created | Accounts Acquired | Avg Deal Size |
|----------|-------------------|------------------------|---------------------------|------------------|-------------------|---------------|
| [REDACTED] | 10.82k | 159k | 14.7 | 69.4k | 8 | 8.7k |
| [REDACTED] | 9.03k | 210k | 23.3 | 79.8k | 6 | 13.3k |


Action Plan:
- Conduct segmentation analysis to the highest-performing subgroups
- Optimize messaging and improve efficiency
- Maintain current scale while working to push efficiency metrics above $25 per company

## High Efficiency, Low Scale (Growth Potential)
These campaigns show promising efficiency but need expansion.

| Campaign | Companies Touched | Pipeline Value Created | Pipeline Value Per Company | Arr Value Created | Accounts Acquired | Avg Deal Size |
|----------|-------------------|------------------------|---------------------------|------------------|-------------------|---------------|
| [REDACTED] | 4,561 | 124.9k | 27.4 | 41.1k | 6 | 6.8k |
| [REDACTED] | 2,059 | 54.0k | 26.2 | 54.0k | 1 | 54.0k |

Action Plan:
- Scale up these campaigns to reach more companies while monitoring efficiency metrics
- Preserve the targeting precision and messaging quality
- Consider developing similar campaigns with high-quality messaging

## Low Efficiency, High Scale (Optimization Needed)
These campaigns reach a significant number of companies but underperform in generating pipeline value per company touched.

| Campaign | Companies Touched | Pipeline Value Created | Pipeline Value Per Company | Arr Value Created | Accounts Acquired | Avg Deal Size |
|----------|-------------------|------------------------|---------------------------|------------------|-------------------|---------------|
| [REDACTED] | 19.3k | 191k | 9.90 | 90.6k | 8 | 11.32k |
| [REDACTED] | 19.0k | 100k | 5.29 | 76.1k | 9 | 8.46k |

Action plan:
- Improve messaging or targeting to increase efficiency
- Develop segment-specific messaging based on industry and company size

## Low Efficiency, Low Scale (Reconsider)
These campaigns underperform on both critical dimensions, indicating fundamental issues.

| Campaign | Companies Touched | Pipeline Value Created | Pipeline Value Per Company | Arr Value Created | Accounts Acquired | Avg Deal Size |
|----------|-------------------|------------------------|---------------------------|------------------|-------------------|---------------|
| [REDACTED] | 4,330 | 44.8k | 10.3 | 44.8k | 2 | 22.4k |
| [REDACTED] | 3,109 | 42.0k | 13.5 | 24.0k | 1 | 24.0k |
| [REDACTED] | 3,092 | 7.2k | 2.3 | 7.2k | 1 | 7.2k |
| [REDACTED] | 752 | 10.8k | 14.4 | 10.8k | 1 | 10.8k |

Action plan:
- Identify specific failure points
- Test new messaging if the segment remains important
- Consider relocating resources to other campaigns

# Size the outbound opportunity
The TAM of [Redacted] consists of 127,000 Shopify merchants with a GMV between $1M and $500M:

| GMV Category | Number of Merchants | % of Total |
| ------------ | --------- | ---------- |
| $1-5M | 84,881 | 66.8% |
| $5-10M | 36,377 | 28.6% | 
| $10-50M | 4,804 | 3.8% |
| $50-100M | 619 | 0.5% |
| $100-500M | 319 | 0.25% |

## Outbound Opportunity Sizing
To estimate the potential New ARR from scaling outbound to our entire TAM, I'll use an approach that aligns with the Top KPI I previously defined: Pipeline Value per Company Touched.

> Potential New ARR = (TAM × Pipeline Value per Company Touched) × Pipeline Revenue Win Rate

- TAM = 127,000 Shopify merchants with GMV between $1M and $500M
- Pipeline Value per Company Touched varies by scenario (based on campaign performance)
- Pipeline Revenue Win Rate = 53.3% (derived from historical data)

This ensures methodological consistency between how we measure campaign performance and how we forecast future opportunity

### Key Caveats
- **Data limited to historical performance**: This analysis assumes future campaigns will perform similarly to past ones, which may not account for market changes, or diminishing returns as we scale.

- **Varying conversion by GMV tier**:  Different GMV tiers likely have different propensities to convert, though our current data doesn't explicitly segment performance by customer size.

- **Pipeline-to-revenue conversion**: I use the historical Pipeline Revenue Win Rate (53.3%) to convert pipeline into ARR, which assumes the sales team will maintain similar close rates at scale.

- **Market saturation effects**: This analysis doesn't account for potential saturation effects from repeatedly targeting the same TAM with similar messaging.

## Opportunity Size Calculations
### Conservative Scenario
Using our average Pipeline Value per Company Touched ($8.70):

| TAM | Pipeline Value/Company | Pipeline Value | Pipeline Revenue Win Rate | Potential ARR |
| --- | ---------------------- | -------------- | ------------------------- | ------------- |
| 127,000 | $8.70 | $1,104,900 | 53.3% | $588,965 |

### Moderate Scenario
Using a midpoint value between average and top performers ($12.85):

| TAM | Pipeline Value/Company | Pipeline Value | Pipeline Revenue Win Rate | Potential ARR |
| --- | ---------------------- | -------------- | ------------------------- | ------------- |
| 127,000 | $12.85 | $1,631,950 | 53.3% | $869,881 |

### Optimistic Scenario
Using values from our best-performing campaigns ($17.00):

| TAM | Pipeline Value/Company | Pipeline Value | Pipeline Revenue Win Rate | Potential ARR |
| --- | ---------------------- | -------------- | ------------------------- | ------------- |
| 127,000 | $17.00 | $2,159,000| 53.3% | $1,150,798 |


## Accounting for Sales Capacity
Current sales capacity: 7 quota-carrying reps × $600K quota = $4.2M yearly capacity

All scenarios fall well within our current sales capacity:

- Conservative scenario: $588,965 (14.0% of capacity)
- Moderate scenario: $869,881 (20.7% of capacity)
- Optimistic scenario: $1,150,798 (27.4% of capacity)

This analysis suggests that scaling our outbound efforts to our entire TAM could generate between $589K and $1.15M in new ARR. This represents a significant achievable growth opportunity that can be handled by the current sales team capacity.

# Prioritizing Outbound as a Growth Lever
## Current Growth Challenge
[Redacted] currently generates $3M in ARR but aims to reach $10M by year-end. This requires an additional $7M in net new ARR. My analysis shows that even with optimistic projections, outbound strategies alone will only deliver between $870K-$1.15M in new ARR.

This creates a clear need for a multi-channel approach to bridge the remaining gap.

## Strategic Channel Assessment

### Outbound Marketing: Precision with Limitations
**Advantages**
- Precision targeting of ICP companies
- Predictable unit economics with controlled scaling
- Direct engagement with decision-makers
- Proven success with campaigns like Technology Intent and Klaviyo Flows Enrich

**Key Challenges**
- With 127,000 total merchants and infrastructures to reach 15,000 monthly contacts, we risk exhausting our addressable ICP
- Increased volume may trigger email spam filters and harm domain reputation
- Maintaining quality at higher volumes becomes increasingly difficult beyond certain volumes
- Contact information accuracy diminishes over time, with a potential impact on email deliverability

### Inbound: Building Sustainable Growth Engines
- Particularly effective for reaching the mid-market (1-10M GMV) segment
- Establishes thought leadership and brand authority
- Generates content like case studies and benchmarks that enhance outbound campaigns and sales enablement

### Paid Acquisition: Accelerating Growth and Awareness
- Enables rapid testing and optimization cycles
- Builds broader market awareness
- Allows precise targeting parameters to reach specific ICPs
- Extends reach beyond the existing Storeleads database

# Recommended Acquisition Channel Mix

## Inbound Foundation 
- Leverage client ecommerce data to create authoritative industry benchmarks and playbooks for each vertical (similar to [Chartmogul SaaS Benchmark Reports](https://chartmogul.com/reports/saas-benchmarks-report/), [Equals guide to SaaS Metrics](https://equals.com/guides/saas-metrics/), [EcommerceFuel Trends Report](https://www.ecommercefuel.com/ecommerce-trends/) or [CTC contents](https://commonthreadco.com/search?q=trend)).
- Develop compelling case studies highlighting specific pain points and measurable outcomes, using internal resources ([example I've done with a client of mine](https://drive.google.com/file/d/19JeAdIlXAQU0cbYteE0yTBGi92ceadUo/view?usp=sharing)) or specialized services like [Testimonial Hero](https://www.testimonialhero.com/).
- Amplify content through owned channels (LinkedIn, Twitter) while securing placement in targeted industry publications and podcasts.
- Channel our inner Anakin and fight with Taylor Holiday on Twitter over marketing attribution 😏

## Paid Acquisition
- Use paid acquisition to build broader market awareness. Could be on LinkedIn, Youtube or Reddit communities.
- Test sponsored content in industry communities / newsletters like [EcommerceFuel](https://www.ecommercefuel.com/), [2PM](https://2pml.com/), and [draft.nu](https://draft.nu/membership/sponsor/).
- Test sponsoring influential industry podcasts like [Honest Ecommerce](https://honestecommerce.co/), [The Unofficial Shopify Podcast](https://unofficialshopifypodcast.com/), and [Ecommerce Conversations](https://www.practicalecommerce.com/tag/podcasts).

## Enhanced Outbound Approach 
- Scale highest-performing campaigns  with refined targeting
- Focus on improving personalization depth rather than simply increasing volume
- Integrate insights + case studies from inbound content to enhance message relevance and credibility

This balanced approach leverages each channel's strengths while building multiple growth engines that can help deliver the ambitious growth target.