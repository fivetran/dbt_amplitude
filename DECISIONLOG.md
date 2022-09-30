
## amplitude_user_id and user_id
Not all customers may be using `user_id` since the field in Amplitude is optional. Therefore for user-based metrics we decided to coalesce `user_id` and `amplitude_id`, for the case where `user_id` may be null.