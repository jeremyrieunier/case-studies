# SQL exercises

## Number of users and the average user level breakdown by user creation date

```sql
select
    created_at as user_creation_date,
    count(user_id) as user_count,
    round(avg(user_level), 2) as avg_user_level
from users
group by user_creation_date
order by user_creation_date
```

| user_creation_date | user_count | avg_user_level |
|--------------------|------------|----------------|
| 2022-05-17 | 1 | 2.5 |
| 2022-08-06 | 3 | 2.5 |
| 2022-09-15 | 1 | 2.0 |
| 2022-10-20 | 1 | 3.0 |
| 2022-11-30 | 1 | 3.0 |
| 2022-12-05 | 1 | 2.5 |
| 2023-02-14 | 2 | 3.0 |
| 2023-03-25 | 1 | 2.0 |
| 2023-08-11 | 2 | 3.0 |
| 2023-08-12 | 1 | 2.0 |

## Number of users who have played at least 1 open match and 1 online court booking match

```sql
-- CTE to get users who've booked courts online
with court_booking_users as (
    select distinct user_id
    from online_court_bookings
    where user_id is not null
),
-- CTE to get users who've played open matches
open_match_users as (
    select distinct user_id
    from open_matches
    where user_id is not null
)

-- Count users who appear in both groups using an inner join
select
    count(c.user_id) as users_played_both
from court_booking_users c
inner join open_match_users o
    on c.user_id = o.user_id
```

| users_played_both |
|-------------------|
| 6 |

## Revenue metrics by user country for online court bookings

```sql
-- CTE to aggregate payment details per booking
with bookings as (
    select
        booking_id,
        owner_id,
        sum(payment_amount) as total_payment,
        sum(b2c_commission_amount) as total_commission
    from online_court_bookings
    group by
        booking_id,
        owner_id    
)

-- Get key metrics by user country using a left join
select
    u.user_country,
    count(booking_id) as booking_count,
    sum(total_payment) as total_payment,
    sum(total_commission) as total_commission,
    round(sum(total_commission) / nullif(sum(total_payment), 0) * 100, 2) as margin_take_rate
from users u
left join bookings b
    on u.user_id = b.owner_id
group by u.user_country
order by booking_count desc
```

| user_country | booking_count | total_payment | total_commission | margin_take_rate |
|--------------|---------------|---------------|------------------|------------------|
| Spain | 2 | 39 | 2.5 | 6.41 |
| France | 2 | 62 | 2.4 | 3.87 |
| Italy | 0 | NULL | NULL | NULL |

## Rank based on the created_at date per match_id for open matches

```sql
select
    match_id,
    user_id,
    created_at,
    dense_rank() over( -- dense_rank() to avoid gaps and keep order sequential
        partition by match_id
        order by created_at
        ) as player_join_order
from open_matches
```

| match_id | user_id | created_at | player_join_order |
|----------|---------|------------|-------------------|
| 15274734 | 345678901 | 2023-11-20T06:03:52 | 1 |
| 15274734 | None | 2023-11-20T07:03:52 | 2 |
| 15274734 | None | 2023-11-20T08:03:52 | 3 |
| 15274734 | None | 2023-11-20T09:03:52 | 4 |
| 55234774 | 456789012 | 2024-03-23T14:03:52 | 1 |
| 55234774 | 521236334 | 2024-03-23T15:03:52 | 2 |
| 55234774 | 736345353 | 2024-03-23T16:03:52 | 3 |
| 55234774 | 264573453 | 2024-03-23T17:03:52 | 4 |
| 77234521 | 678901234 | 2023-12-15T10:03:52 | 1 |
| 77234521 | 789012345 | 2023-12-15T11:03:52 | 2 |
| 77234521 | None | 2023-12-15T12:03:52 | 3 |
| 77234521 | None | 2023-12-15T13:03:52 | 4 |
| 88234666 | 901234567 | 2024-03-25T18:03:52 | 1 |
| 88234666 | 012345678 | 2024-03-25T19:03:52 | 2 |
| 88234666 | 678901234 | 2024-03-25T20:03:52 | 3 |
| 88234666 | 789012345 | 2024-03-25T21:03:52 | 4 |

## Funnel analysis to see, per user creation year, the conversion from user creation to an open match.

```sql
-- CTE to get the user creation year for each user
with user_creation as (
    select
        user_id,
        date_part('year', cast(created_at as date)) as creation_year
    from users
),
-- CTE to get the users who participated in an open match
users_open_match as (
    select distinct user_id
    from open_matches
    where user_id is not null
)

select
    u.creation_year as creation_year,
    count(u.user_id) as total_users,
    count(o.user_id) as users_played_open_match,
    round(count(o.user_id) / count(u.user_id) * 100, 2) as open_match_conversion_rate
from user_creation u
left join users_open_match o
    on u.user_id = o.user_id
group by u.creation_year
order by u.creation_year
```

| creation_year | total_users | users_played_open_match | open_match_conversion_rate |
|---------------|-------------|-------------------------|-----------------------------|
| 2022 | 8 | 5 | 62.5 |
| 2023 | 6 | 3 | 50.0 |