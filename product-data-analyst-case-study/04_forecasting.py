import streamlit as st
import pandas as pd
from streamlit_gsheets import GSheetsConnection
from prophet import Prophet

gsheet_url = "https://docs.google.com/spreadsheets/d/1ttEndNyIecRf7Arm-lhZrcSIh1vWUmEtTYrCGE9dCSU/edit?gid=69050303#gid=69050303"

# variables to calculate MTU cost
contract_MTU = 1000000
base_yearly_cost = 5000
additional_cost = 0.006

# function to calculate MTU cost
def calculate_cost(total_MTU):
    if total_MTU <= contract_MTU:
        return base_yearly_cost
    additional_MTU = total_MTU - contract_MTU
    return round(base_yearly_cost + (additional_MTU * additional_cost))

conn = st.connection("gsheets", type=GSheetsConnection)
MTU_data = conn.read(spreadsheet=gsheet_url, usecols=[0, 1])

# rename columns for Prophet
MTU_data.columns = ['ds', 'y']
MTU_data['ds'] = pd.to_datetime(MTU_data['ds'])

# create and fit model
m = Prophet()
m.fit(MTU_data)
future = m.make_future_dataframe(periods=11, freq="M") 
forecast = m.predict(future)

# replace January and February 2024 predictions with actual data
jan_feb_2024_data = MTU_data[MTU_data['ds'].dt.year == 2024]
forecast.loc[forecast['ds'].isin(jan_feb_2024_data['ds']), 'yhat'] = jan_feb_2024_data['y'].values

# forecast calculations for 2024
forecast_2024 = forecast[forecast['ds'].dt.year == 2024][['ds', 'yhat', 'yhat_lower', 'yhat_upper']]
forecast_2024['running_total'] = forecast_2024['yhat'].cumsum()
forecast_2024['running_total_lower'] = forecast_2024['yhat_lower'].cumsum() 
forecast_2024['running_total_upper'] = forecast_2024['yhat_upper'].cumsum()
forecast_2024['yearly_cost'] = forecast_2024['running_total'].apply(calculate_cost)
forecast_2024['yearly_cost_lower'] = forecast_2024['running_total_lower'].apply(calculate_cost)
forecast_2024['yearly_cost_upper'] = forecast_2024['running_total_upper'].apply(calculate_cost)

# MTU forecast calculations for 2024
final_MTU = forecast_2024['running_total'].iloc[-1]
final_MTU_lower = forecast_2024['running_total_lower'].iloc[-1]
final_MTU_upper = forecast_2024['running_total_upper'].iloc[-1]

# find when we cross 1M
crossing_point = forecast_2024[forecast_2024['running_total'] > 1000000].iloc[0]
crossing_point_lower = forecast_2024[forecast_2024['running_total_lower'] > 1000000].iloc[0]
crossing_point_upper = forecast_2024[forecast_2024['running_total_upper'] > 1000000].iloc[0]

# convert date for formatting
base_date = pd.to_datetime(crossing_point['ds']).strftime('%B %Y')
lower_date = pd.to_datetime(crossing_point_lower['ds']).strftime('%B %Y')
upper_date = pd.to_datetime(crossing_point_upper['ds']).strftime('%B %Y')

# format dates for display
forecast_2024['ds'] = forecast_2024['ds'].dt.strftime('%Y-%m-%d')

# calculate additional MTU costs
additional_cost = forecast_2024['yearly_cost'].iloc[-1]
additional_cost_lower = forecast_2024['yearly_cost_lower'].iloc[-1]
additional_cost_upper = forecast_2024['yearly_cost_upper'].iloc[-1]

st.title("📈 Forecasting with Prophet")

st.markdown(f"""             
# Forecast for 2024 accounts for a running total of {final_MTU:,.0f} MTU
- Conservative estimate: {final_MTU_lower:,.0f}
- Optimistic estimate: {final_MTU_upper:,.0f}
""")

st.markdown(f"""
### Based on the forecast, we'll reach 1M MTU in:
- Base scenario: {base_date} with {crossing_point['running_total']:,.0f} MTU
- Conservative: {lower_date} with {crossing_point_lower['running_total_lower']:,.0f} MTU
- Optimistic: {upper_date} with {crossing_point_upper['running_total_upper']:,.0f} MTU             
""")

st.line_chart(
    forecast_2024.set_index('ds')[['running_total', 'running_total_lower', 'running_total_upper']]
)

# Forecast costs for 2024
st.markdown(f"""
    ### This will incur an aditional cost of up to ${additional_cost_upper - base_yearly_cost:,}:
    - Base scenario: additional cost of ${additional_cost - base_yearly_cost:,} for a total of &#36;{additional_cost:,}
    - Conservative: additional cost of ${additional_cost_lower - base_yearly_cost:,} for a total of &#36;{additional_cost_lower:,}
    - Optimistic: additional cost of ${additional_cost_upper - base_yearly_cost:,} for a total of &#36;{additional_cost_upper:,}
""")

st.line_chart(
    forecast_2024.set_index('ds')[['yearly_cost', 'yearly_cost_lower', 'yearly_cost_upper']]
)

# Plot the forecast
st.markdown("""
### 2024 forecast with confidence intervals:
""")
fig1 = m.plot(forecast)
st.pyplot(fig1)

st.markdown("""
### 2024 Monthly Forecast table:
""")
st.dataframe(forecast_2024.round(0))

st.markdown("---")
st.markdown("Forecast made with Python using [Prophet](https://facebook.github.io/prophet/docs/quick_start.html")