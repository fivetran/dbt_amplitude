# Decision Log
## amplitude_user_id and user_id
Not all customers may be using `user_id` since the field in Amplitude is optional. Therefore, when handling user-based metrics we take the opinionated stance to coalesce `user_id` and `amplitude_user_id`. This way, if your Amplitude account does not utilize `user_id` you may still take advantage of user-based metrics with the `amplitude_user_id`.
