JekyllBot
=========

Listens for GitHub post-recieve service hooks messages, runs jekyll, and pushes the results back to GitHub. Designed to be run on Heroku to generate JSON representations of postdata for ben.balter.com.

Usage
-----

1. `git clone`
2. `heroku create`
3. Add resulting URL to Repo's Settings > Service Hooks > WebHook URLs
4. _optional_ Create an application on [Github](https://github.com/settings/applications/new)
    * Add Heroku URL to Main URL
    * Add Heroku URL + `/auth/github/callback` to Callback URL
5. _optional_ Add the Client Id and Client Secret to Heroku config
    * `heroku config:set GITHUB_CLIENT_ID=YOUR_CLIENT_ID GITHUB_CLIENT_SECRET=YOUR_SECRET`
6. _optional_ Go to your Heroku URL and select "try to authorize" to get an Oauth Token
7. Add github credentials or an oauth token to Heroku config
    * `heroku config:set GITHUB_USER=YOUR_GITHUB_USER_NAME GITHUB_PASS=YOUR_PASSWORD`
    * `heroku config:set GUTHUB_USER=OAUTH_TOKEN`

Will automatically fire on each commit
