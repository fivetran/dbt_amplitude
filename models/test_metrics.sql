select * 
from {{ metrics.calculate(
        metric('total_events'),
        grain='month',
        dimensions=['region'],
        secondary_calculations=[
            metrics.period_over_period(comparison_strategy='ratio', interval=1, alias='ratio_last_mth'),
            metrics.period_over_period(comparison_strategy='ratio', interval=12, alias='ratio_last_yr'),
            metrics.period_to_date(aggregate='sum', period='year', alias='ytd')
        ]
) }}