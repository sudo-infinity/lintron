# Lintron

Automatically lints Github Pull Requests and posts lints as review comments.

## Setup

```
bundle install
```

Lintron uses a GitHub machine user to make the comments. You just set up a separate user for it and set up a new developer application for that user. Then, you will need a .env file containing to the following keys:

```
GITHUB_USERNAME=…from the github user
GITHUB_TOKEN=…from the github user
GITHUB_WEBHOOK_SECRET=…make up a secret shared between lintron and github
GITHUB_APP_ID=…the developer application's id
GITHUB_APP_SECRET=…the developer application's secret
```

## Setting Up Webhooks

Lintron uses webhooks to know when a PR has been created or updated. You'll need to set up the webhook on each repo you want Lintron to monitor.

![Webhooks](https://raw.githubusercontent.com/prehnRA/lintron/master/960px-Webhook3.png)

The webhook url will be https://yourlintronhost/github_webhooks. The secret will be the one you set in your .env file. Lintron needs to be on a publicly reachable host to receive webhooks.
