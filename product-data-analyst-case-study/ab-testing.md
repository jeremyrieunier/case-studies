## Product overview
The business is an application that connects Padel and Tennis clubs with players through 2 main products:

1. Online court bookings: Users can reserve and pay for a court in advance, then either share the booking link with others or organise the match externally.
2. Open matches: Users can reserve and pay to join existing matches, eliminating the need to find additional players.

The primary user goal is straightforward: to play Padel or Tennis. Bonus point if it's with Rafa. This suggests the ⭐ North Star metric is probably related to the number of weekly active players or the average number of games a user plays over a week/month.

## Revenue model
The application generates revenue through commissions on both booking types (court reservations and open matches). Therefore, the business success is directly tied to 2 key conversion metrics:
1. Open match conversion rate
2. Court booking conversion rate

## Problem statement
The product team wants to improve the open match conversion rate for several reasons:
1. Open matches provide faster value to our users as they require "less effort" than booking a court.
2. Current court utilisation (and resulting commission revenue) may be suboptimal.
3. Business might be missing opportunities to foster community engagement through social play.

 ## Hypothesis
We believe that displaying recommended open matches during the court booking flow will increase open matches conversion rate because:
1. It improves open-match discovery.
2. It presents an easier alternative at a moment of high intent. Users have their mobile in one hand and their 💳 credit card in the other hand.
3. It reduces frictions in finding recommended matches.

To test this hypothesis the product team will implement a carrousel of personalised recommended matches within the court booking flow.

This context sets up our experiment analysis and helps frame my approach to the specific questions that follow.

## Experiment duration
First and foremost, this experiment should have a minimum duration requirement of at least 4 weeks. It should be long enough to account for:

- Weekly booking patterns (weekday vs weekend differences)
- User behaviour variations (regular vs occasional players)
- Potential novelty effects with the carousel feature

But not so long that we risk:

- Sample pollution from seasonality, weather and other external events
- Users changing attributes (new to returning)
- Overlap with other experiments that could affect interpretation

Now, we also need to consider several key factors to calculate the exact duration.

### Minimum Detectable Effect (MDE)
First, we need to know our current open match conversion rate and what minimum improvement would be meaningful for the business. I recommend setting an MDE of 10-20% relative improvement because:

- Smaller improvements wouldn't justify the added complexity
- The change needs to meaningfully impact overall business metrics
- The feature's placement in the booking flow suggests the potential for a significant impact

### Statistical parameters
We'll use standard parameters for statistical requirements since we want to optimise test velocity while maintaining reliable results. This translates to:

- 95% confidence level (significance level = 0.05)
- 80% statistical power
- 50/50 traffic split between control and treatment groups

### Final duration calculation
We will need the following to determine the exact duration:

- Average daily users entering the court booking flow
- Current baseline conversion rate for open match participation
- Confirmation that a 10-20% relative improvement aligns with stakeholder expectations

With these data, we will be able to determine the sample size needed and translate that into a specific test duration based on our traffic/user volume.         

## Recommended rollout strategy
### Randomisation approach
First, we have to choose if we want to implement the experimentation and its randomisation at the session level or user level. I'd recommend implementing user level randomisation to:

- Maintain consistent user experience across sessions
- Enable tracking of cumulative exposure and conversion
- Ensure clean measurement of the carousel's impact on open match conversion

### Phased Implementation
Each phase should be treated as a separate experiment with clear start/end dates to avoid continuous traffic adjustments.

#### Initial A/A test phase (2 - 5 days)
Before launching our main experiment, we need to validate our measurement system and ensure we're collecting data correctly. During this phase, we will:

- Begin with a small sample of users to validate measurement systems
- Run this to ensure our instrumentation is working correctly
- Establish accurate baseline metric tracking

#### Conservative rollout (1 week)
Once we've confirmed our measurement system is working properly, we'll start with a conservative rollout to identify any potential issues early. In this phase, we will:

- Start with a 20% treatment group vs 80% control to provide enough traffic to catch major issues
- Monitor carefully for any negative impacts on the related metrics (primary and guardrail)

#### Full Experiment rollout (> 4 weeks)
If the initial controlled experiment shows neutral or positive results, we'll proceed with the full rollout. During this final phase, we will:

- Expand to the full test size (50% treatment, 50% control)
- Run until we reach statistical significance
- Monitor for any changes in effect size as we scale

This structured approach ensures we can safely validate our hypothesis while protecting the user experience and business metrics.
            
Which leads us to...

## Metrics to track for this experiment
The primary metric will be the user open match conversion rate, as it directly ties to our hypothesis and will validate its success. This metric is defined as:

`Number of users who join an open match / Total number of users who visited the app`

Other important business metrics like revenue per user, weekly active players, and engagement metrics should be classified as:

- Guardrail metrics (to ensure we don't harm them)
- Tracking metrics (to help explain movements in our primary metric)
- Lagging indicators (to monitor post-launch)

### Guardrail metrics
We should track 3 types of guardrail metrics to ensure comprehensive monitoring

First is a business metric to ensure we protect business economics and catch any negative impact on platform monetisation. For this experiment, it should be the overall revenue per user:

`(Commissions from court bookings + Commissions from open matches) / Total unique users`

Second is a success metric to ensure we're not losing booking opportunities overall while accounting for the intended shift from court bookings to open matches. In this case, it should be the overall booking conversion rate:

`Number of completed court bookings + Number of completed open matches bookings) / Number of users who started a booking flow`

Finally, a UX metric to ensure we're not introducing decision paralysis in the court booking flow. It should be the average time to complete a booking.

`Average time (in seconds) between when a user enters the court booking flow and when they complete a booking transaction`

## How to validate the hypothesis
We expect to observe 2 distinct patterns when analysing the results of this experiment.

In the control group, where users follow the standard court booking flow, it should be business as usual with:
- Court booking and open-matches conversion rate remain the same
- Normal booking completion times
- Regular booking abandonment rate

On the other hand for the treatment group exposed to the carousel feature, we anticipate positive changes in user behaviour, specifically:
- A statistically significant increase of 10-20% in user open match conversion rate
- Evidence of users discovering and switching from court bookings to recommended open matches
- Higher discovery and engagement with open-match options

Whilst driving these improvements, our defined guardrail metrics should remain within acceptable thresholds:
- Overall revenue per user should maintain or increase
- Overall booking conversion rate should not significantly decrease
- The average time to complete a booking should not substantially increase
            
In a nutshell, if our hypothesis is valid, we should observe increased open match participation without compromising the core booking experience or overall business metrics. Finger crossed 🤞.