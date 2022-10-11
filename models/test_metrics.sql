select * 
from {{ metrics.calculate(
        metric('total_events'),
        grain='day',
        dimensions=['country']
) }}